block-level on error undo, throw.
/*

$Revision: 55e470c22f96, 3463, rls $
$Author: VSpiridonov $
$Date: 2023/10/16 15:13:34 $
$Workfile: checkp.p $
$Archive: str/checkp.p $

Печать одного чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER cdoc like chk-doc.doc-code.

define variable vss-revision    as character no-undo init "$Revision: 55e470c22f96, 3463, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:34 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: checkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/checkp.p $":U .
define variable vss-description as character no-undo init "Печать одного чека".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ str/shftnmef.i chk-doc shift-name }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }

define variable sym1           as char      format "X(1)" init ":".
define variable sym10          as char      format "X(1)" init ":".
define variable date_string    as char      no-undo.
define variable Line           as char      no-undo.
define variable for-time       as char.
define variable for-gds-sum    like chk-doc.netto no-undo.
define variable for-gds-price  like chk-gds.price-base no-undo.
define variable fgds-discnt-pc as decimal   no-undo.
define variable accum-pay-r-b  as decimal   no-undo .
define variable v-curr-r-b     as character no-undo .
define variable v-is-write-off as logical   no-undo .
define variable itog-doc-qnty as decimal no-undo .
define variable itog-price-service as decimal no-undo .
define variable itog-discnt as decimal no-undo .
define variable itog-discnt-pc as decimal no-undo .
define variable itog-gds-sum as decimal no-undo .
define variable itog-gds-price as decimal no-undo .
define variable itog-tot-sum as decimal no-undo .
define variable itog-tot-base as decimal no-undo .
define variable itog-tot-rubl as decimal no-undo .

define variable v-attr-rnn as character no-undo .
define variable v-attr-sbprrn as character no-undo .
define variable v-fix   as character no-undo .
define variable v-fix-png  as character no-undo .

define variable v-arc as character no-undo .
define buffer buf_chk-pay-attr for ub.chk-pay-attr .

define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .

FIND FIRST chk-doc NO-LOCK WHERE chk-doc.doc-code = cdoc NO-ERROR.
IF NOT avail chk-doc then return.

FOR EACH chk-pay No-LOCK where chk-pay.doc-code = chk-doc.doc-code:
   assign
      accum-pay-r-b = accum-pay-r-b +
              (if v-curr-r-b = {&r-b-base}
                then chk-pay.tot-base
                else chk-pay.tot-rubl)
      .
END.

if NOT chk-doc.d-card = "" then 
do:
   FIND FIRST dis-card NO-LOCK WHERE dis-card.d-card = chk-doc.d-card NO-ERROR.
   IF avail dis-card then 
   do:
      FIND FIRST clients where clients.obj-type = dis-card.cli-type AND
         clients.obj-code = dis-card.cli-code No-ERROR.
   END.
end.

      assign
        v-arc = search( "exe/qrgen.exe":U )
        .
      if v-arc = ? then 
      do:
        message "Не найдена программа qrgen.exe" 
        view-as alert-box.
         
         return error .
      end.   
/*      Пример формата: t=20150720T1638&i=12345678&n=1      */
/*                                                          */
/*t-датавремя, i - номер чека,  n - тип документа (1-приход)*/
/*                                                          */
/*Формат даты: формат такой ГГГГММДДTЧЧММ                   */
/*                                                          */
      
      define variable v-date as character no-undo .
      
      v-date = "20" + entry(3,string(chk-doc.chk-date),"/") + entry(2,string(chk-doc.chk-date),"/") + entry(1,string(chk-doc.chk-date),"/").
     
      v-fix = "t=" + v-date + "T" + replace(string(chk-doc.chk-time,"HH:MM"),":","") + "&i=" + string(chk-doc.chk-num) + "&n=" + string(chk-doc.chk-type) .
      os-command silent value (v-arc + ' -size=128 -content="' + v-fix + '"' + ' -filename="' + string(session :temp-directory) + 'qr-code_fix"') .
      v-fix-png = string(session :temp-directory) + "qr-code_fix" + ".png" .

find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "sbprrn" and
                                          buf_chk-pay-attr.doc-code = chk-doc.doc-code 
                                          and buf_chk-pay-attr.attr-value <> "" no-error .
                                          
if available (buf_chk-pay-attr) then do:
      os-command silent value (v-arc + ' -size=128 -content="' + buf_chk-pay-attr.attr-value + '"' + ' -filename="' + string(session :temp-directory) + 'qr-code_sbprrn"') .
      v-attr-sbprrn = string(session :temp-directory) + "qr-code_sbprrn" + ".png" .

end.                                          
find first buf_chk-pay-attr no-lock where (buf_chk-pay-attr.attr-code = "RRN" or buf_chk-pay-attr.attr-code = "cpdoc") and
                                          buf_chk-pay-attr.doc-code = chk-doc.doc-code 
                                          and buf_chk-pay-attr.attr-value <> "" no-error .
if available (buf_chk-pay-attr) then do:
      os-command silent value (v-arc + ' -size=128 -content="' + buf_chk-pay-attr.attr-value + '"' + ' -filename="' + string(session :temp-directory) + 'qr-code_rrn"') .
      v-attr-rnn = string(session :temp-directory) + "qr-code_rrn" + ".png" .   
end.   
                                          
/*Line = fill("-", 198).*/
date_string = cur-time-print() .

/*печать*/
run get-report-num (output p-report-id).
    
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
                        
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
put stream OutStr-html unformatted
   "<!DOCTYPE HTML>" skip
   ' <html>' skip
   '  <head>' skip
   '   <meta charset="utf-8">' skip
   '    <style type="text/css">' skip
                        
   '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
   '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
   '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
   '   </style>' skip
   '  </head>' skip
   .
 
 
put stream OutStr-html unformatted
   '<body>' skip
   /*Первая таблица*/
   '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
   '<thead>' skip
   .
put stream OutStr-html unformatted
   '<tr class="set_columns">' skip
   '<td style="width: 20px;"></td>' skip
   '<td style="width: 15px;"></td>' skip
   '<td style="width: 20px;"></td>' skip
   '<td style="width: 30px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 120px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 60px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 20px;"></td>' skip
   '<td style="width: 20px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 60px;"></td>' skip
   '<td style="width: 60px;"></td>' skip
   '<td style="width: 80px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '</tr>' skip
   .
                        
 
put stream OutStr-html unformatted  
   '<TR>'skip
   '<TD colspan="14" style="font-weight: bold;">' + string(date_string) + '</TD>' skip
   '<TD colspan="4" style="text-align: center;">Для поиска чека на кассе</TD>' skip
   '<TD colspan="3" style="text-align: center;">RRN</TD>' skip
   '<TD colspan="3" style="text-align: center;">SBPRRN</TD>' skip
   '</TR>' skip 
   '<TR>'skip
   '<TD colspan="14" style="font-weight: bold;">Чек N ' + string(chk-doc.doc-code) + ' Магазин N ' + string(chk-doc.obj-code) + ' Дата: ' + string(chk-doc.chk-date, "99/99/9999") + ' Время: ' + string(chk-doc.chk-time, "HH:MM") + ' Дата смены: ' + string(chk-doc.shift-date, "99/99/9999") + ' Номер смены: ' + shift-name-no-err(buffer chk-doc) + '</TD>' skip
   .
     if search(v-fix-png) <> ? then 
  do:  
    put stream OutStr-html unformatted  
      '<TD text_wrap="true" rowspan="5" colspan="4" style="text-align: center;"><img src="' + string(v-fix-png)+ '" width="130" height="130" alt=""/></TD>' skip
      .
  end.
  else 
  do:
    put stream OutStr-html unformatted  
      '<TD rowspan="5" colspan="4"></TD>' skip
      .

  end.  
  
     if search(v-attr-rnn) <> ? then 
  do:  
    put stream OutStr-html unformatted  
      '<TD text_wrap="true" rowspan="5" colspan="3" style="text-align: center;"><img src="' + string(v-attr-rnn)+ '" width="130" height="130" alt=""/></TD>' skip
      .
  end.
  else 
  do:
    put stream OutStr-html unformatted  
      '<TD rowspan="5" colspan="3"></TD>' skip
      .

  end.  
     if search(v-attr-sbprrn) <> ? then 
  do:  
    put stream OutStr-html unformatted  
      '<TD text_wrap="true" rowspan="5" colspan="3" style="text-align: center;"><img src="' + string(v-attr-sbprrn)+ '" width="130" height="130" alt=""/></TD>' skip
      .
  end.
  else 
  do:
    put stream OutStr-html unformatted  
      '<TD rowspan="5" colspan="3"></TD>' skip
      .
  end.    

put stream OutStr-html unformatted  
   '</TR>' skip 
   '<TR>'skip
   '<TD colspan="14" style="font-weight: bold;">Касса N ' + string(chk-doc.pay-desk) + ' Номер по кассе ' + string(chk-doc.chk-num) + ' Кассир: ' + if chk-doc.cashier <> ? then string(chk-doc.cashier) else "" + ' Продавец: ' + if chk-doc.sales-man <> ? then string(chk-doc.sales-man) else "" + '</TD>' skip
   '</TR>' skip
   .

if NOT chk-doc.d-card = "" then 
do:
   if available (clients) then 
   do:
      put stream OutStr-html unformatted     
         '<TR>'skip
         '<TD colspan="14" style="font-weight: bold;">Дисконтная карта №: ' + string(chk-doc.d-card) + ' Клиент: ' + string(clients.obj-name) + ' Сумма товарная: ' + string(chk-doc.tot-doc,"->>>,>>>,>>9.99") + '</TD>'
         '</TR>' skip
         .
   end.
   else 
   do:
      put stream OutStr-html unformatted     
         '<TR>'skip
         '<TD colspan="14" style="font-weight: bold;">Дисконтная карта №: ' + string(chk-doc.d-card) + ' Сумма товарная: ' + string(chk-doc.tot-doc,"->>>,>>>,>>9.99") + '</TD>'
         '</TR>' skip
         .
   end.      
end.

if chk-doc.sub-discnt <> 0 then 
do:
   put stream OutStr-html unformatted  
      '<TR>'skip
      '<TD colspan="14" text_wrap="true" style="text-align: left; font-weight: bold;">Скидка общая: ' + string((chk-doc.discnt),"->>>>>>>>>>>9.99") + ' Списание: ' + string(chk-doc.sub-discnt, "->>>,>>>,>>9.99") + ' Процент скидки: ' + string((if chk-doc.tot-doc = 0 then 0 else ( chk-doc.discnt / chk-doc.tot-doc * 100 ) ), "->9.99%") + '</TD>' skip
      '</TR>' skip 
      .
end.
else 
do:
   put stream OutStr-html unformatted  
      '<TR>'skip
      '<TD colspan="14" text_wrap="true" style="text-align: left; font-weight: bold;">Скидка общая: ' + string((chk-doc.discnt),"->>>>>>>>>>>9.99") + ' Списание: ' + string(chk-doc.sub-discnt, "->>>,>>>,>>9.99") + ' Процент скидки: ' + string((if chk-doc.tot-doc = 0 then 0 else ( chk-doc.discnt / chk-doc.tot-doc * 100 ) ), "->9.99%") + '</TD>' skip
      '</TR>' skip 
      . 
end.   
put stream OutStr-html unformatted
   '<TR>'skip
   '<TD colspan="14" style="font-weight: bold;">Сумма нетто: ' + string(chk-doc.netto, "->>>,>>>,>>9.99") + ' Сумма оплат: ' + string(ACCUM-pay-r-b, "->>>,>>>,>>9.99") + '</TD>' skip
   '</TR>' skip 
   '<TR>'skip
   '<TD colspan="14" style="font-weight: bold;">ТОВАРЫ ПО ЧЕКУ:</TD>' skip
   '</TR>' skip 
   '<TR height: 14px;>'skip
   '<TD colspan="14" style="font-weight: bold; border-bottom: 1px solid black;"></TD>' skip
   '</TR>' skip 
   .

put stream OutStr-html unformatted
   '<TR>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">NN</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Код</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Артикул</TD>' skip
   '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver; border-top: 1px solid black;">Название/</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Ош</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Код в спул-файле</TD>' skip
   '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver; border-top 1px solid black;">ТРК</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Количество</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Изм</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Цена</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Скидка</TD>' skip    
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">% ск</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Цена нетто</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Сумма по строке</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Дорожный налог</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Спи</TD>' skip
   '</TR>'skip       
   '<TR>'skip
   '<TD text_wrap="true" colspan="2" rowspan="2" style="text-align: center; font-weight: bold; background-color: silver; border-bottom: 1px solid black;">Производитель</TD>' skip
   '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Пист</TD>' skip
   '</TR>'skip
   '<TR>'skip
   '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver; border-bottom: 1px solid black;">Рез</TD>' skip
   '</TR>'skip
   .
FOR EACH chk-gds No-LOCK where
   chk-gds.doc-code = chk-doc.doc-code
   by abs(CHk-gds.line-num ):
   FIND FIRST bar-code No-LOCK WHERE bar-code.b-code = chk-gds.b-code NO-ERROR.
   IF AVAIL bar-code then 
   do:
      FIND FIRST goods NO-LOCK WHERE
         goods.gds-code = bar-code.gds-code NO-ERROR.
      FIND FIRST  clients NO-LOCK WHERE
         clients.obj-type = goods.prod-type AND
         clients.obj-code = goods.prod-code NO-ERROR.
      FIND FIRST gds-prt No-LOCK where gds-prt.upper-code = goods.prt-root NO-ERROR.
   end.

   assign
      fgds-discnt-pc = (chk-gds.discnt / (chk-gds.price-base + chk-gds.price-service) * 100)
      for-gds-sum    = (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt) * chk-gds.doc-qnty
      for-gds-price  = chk-gds.price-base + chk-gds.price-service - chk-gds.discnt
      .

   put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; border: 1px solid black;">' + string(chk-gds.line-num) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; border: 1px solid black;">' + string(chk-gds.b-code) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center; border-top: 1px solid black; border-right: 1px solid black;">' + if avail bar-code then goods.artic + '</TD>' else "" + '</td>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center; border-top: 1px solid black; border-right: 1px solid black;">' + if avail bar-code then goods.gds-name + '</TD>' else "" + '</td>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: center; border: 1px solid black;">' + if chk-gds.is-error then "yes" + '</TD>' else "no" + '</TD>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; border: 1px solid black;">' + string(chk-gds.src-code) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; border-top: 1px solid black;">' + string(chk-gds.pump) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-gds.doc-qnty,"->>>>>>>>>>>9.999") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: center; border: 1px solid black;">' + if avail bar-code then string(bar-code.unit-cli) + '</TD>' else "" + '</TD>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: right; border: 1px solid black;">' + string((chk-gds.price-base + chk-gds.price-service),"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-gds.discnt,"->>>>>>>>>>>9.99") + '</TD>' skip    
      '<TD text_wrap="true" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(fgds-discnt-pc,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(for-gds-price,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(for-gds-sum,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-gds.road-tax,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: right; border: 1px solid black;">' + if chk-gds.write-off-code <> ? and chk-gds.write-off-code <> 0 then "yes" + '</TD>' else "no" + '</TD>' skip
      '</TR>'skip     
      '<TR>' skip
      .
      if avail bar-code then do:
         put stream OutStr-html unformatted
      '<TD text_wrap="true" colspan="2" rowspan="2" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;">' + IF ub.gds-prt.node-name <> {&empty-scale} then string(gds-prt.f-name) + '</TD>' else "" + '</td>' skip .
      end.
      else do:
         put stream OutStr-html unformatted
      '<TD text_wrap="true" colspan="2" rowspan="2" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;"></TD>'
      .
      end.      
      put stream OutStr-html unformatted
    '<TD text_wrap="true" colspan="2" rowspan="2" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;">' + if avail bar-code then clients.obj-name + '</TD>' else "" + '</td>' skip
    '<TD text_wrap="true" style="text-align: center;">' +  if chk-gds.nozzle-code <> 0 then string(chk-gds.nozzle-code) + '</TD>' else "" + '</TD>' skip
    '</TR>' skip  
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; border-bottom: 1px solid black;">' + if chk-gds.loc1 <> "" then string(chk-gds.loc1) + '</TD>' else "" + '</TD>' skip
    '</TR>' skip  
      .
assign
itog-doc-qnty = itog-doc-qnty + chk-gds.doc-qnty
itog-price-service = itog-price-service + ((chk-gds.price-base + chk-gds.price-service) * chk-gds.doc-qnty)
itog-discnt = itog-discnt + (chk-gds.discnt * chk-gds.doc-qnty)
itog-gds-sum = itog-gds-sum + ((chk-gds.price-base + chk-gds.price-service - chk-gds.discnt) * chk-gds.doc-qnty)
.
END.

put stream OutStr-html unformatted
   '<TR>' skip
   '<TD text_wrap="true" colspan="12" style="font-weight: bold; text-align: right;"></TD>' skip
   '<TD text_wrap="true" colspan="2" style="font-weight: bold; text-align: right;">' + string(itog-doc-qnty,"->>>>>>>>>>>9.999") + '</TD>' skip
   '<TD text_wrap="true"></TD>' skip
   '<TD text_wrap="true" colspan="2" style="font-weight: bold; text-align: right;">' + string(itog-price-service,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true" colspan="2" style="font-weight: bold; text-align: right;">' + string(itog-discnt,"->>>>>>>>>>>9.99") + '</TD>' skip    
   '<TD text_wrap="true" style="font-weight: bold; text-align: right;">' + string((itog-discnt / (itog-price-service * 100)),"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true"></TD>' skip
   '<TD text_wrap="true" style="font-weight: bold; text-align: right;">' + string(itog-gds-sum,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true" colspan="2"></TD>' skip
   '</TR>'skip   
   .

put stream OutStr-html unformatted
   '<TR>'skip
   '<TD text_wrap="true" colspan="18" style="font-weight: bold;">ОПЛАТЫ ПО ЧЕКУ</TD>' skip
   '<TD colspan="6"></TD>' skip
   '</TR>'skip
   '<TR height: 14px;>'skip
   '<TD colspan="18" style="font-weight: bold;"></TD>' skip
   '<TD colspan="6" style="font-weight: bold; 0px solid white;"></TD>' skip
   '</TR>' skip    
   '<TR>' skip
   '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">NN</TD>' skip
   '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Код. вал</TD>' skip
   '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Валюта</TD>' skip
   '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Код платежа</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Платеж</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Сумма в вал. платежа</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Сумма в баз.вал</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Сумма в рублях</TD>' skip
   '<TD text_wrap="true" style="border-top: 0px solid white;"></TD>' skip .
   put stream OutStr-html unformatted   
   '<TD text_wrap="true" colspan="4" style="border-top: 0px solid white;"></TD>' skip 
   '</TR>'skip       
   .

FOR EACH chk-pay No-LOCK WHERE
   chk-pay.doc-code = chk-doc.doc-code
   by CHk-pay.line-num :
   FIND FIRST currency No-LOCK WHERE currency.curr-code = chk-pay.curr-code NO-ERROR.
   FIND FIRST cash-pay No-LOCK WHERE
      cash-pay.cdpay-code = chk-pay.pay-code AND
      cash-pay.curr-code = chk-pay.curr-code No-ERROR.
   assign
      itog-tot-sum = itog-tot-sum + chk-pay.tot-sum
      itog-tot-base = itog-tot-base + chk-pay.tot-base
      itog-tot-rubl = itog-tot-rubl + chk-pay.tot-rubl
      .
      
   put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(chk-pay.line-num) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center; border: 1px solid black;">' + string(chk-pay.curr-code) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center; border: 1px solid black;">' + if available (currency) then currency.curr-name + '</TD>' else "НЕОПОЗНАННАЯ ВАЛЮТА" + '</TD>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center; border: 1px solid black;">' + string(chk-pay.pay-code) + '</TD>' skip
      '<TD text_wrap="true" colspan="3" style="text-align: center; border: 1px solid black;">' + if available (cash-pay) then cash-pay.obj-name + '</TD>' else "НЕОПОЗНАННАЯ ОПЛАТА" + '</TD>' skip
      '<TD text_wrap="true" colspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-pay.tot-sum,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" colspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-pay.tot-base,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" colspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-pay.tot-rubl,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true" colspan="4"></TD>' skip
      '</TR>'skip       
      .    
END.




/* ФН – номер фискального накопителя (атрибут чека CHNumberFN), 
ФД – порядковый номер фискального документа (атрибут чека CHFiscalDocNumber)
ФПД – номер фискального признака документа (атрибут чека CHFiscalDocSign) */ 

define variable NumberFN as character no-undo .
define variable FiscalDocNumber as character no-undo .
define variable FiscalDocSign as character no-undo .

find first chk-doc-attr where chk-doc-attr.attr-code = 'CHNumberFN' and chk-doc-attr.doc-code = chk-doc.doc-code no-lock no-error.
IF AVAILABLE chk-doc-attr THEN DO: 
NumberFN = chk-doc-attr.attr-value.
end.

find first chk-doc-attr where chk-doc-attr.attr-code = 'CHFiscalDocNumber' and chk-doc-attr.doc-code = chk-doc.doc-code no-lock no-error.
IF AVAILABLE chk-doc-attr THEN DO: 
FiscalDocNumber = chk-doc-attr.attr-value.
end.

find first chk-doc-attr where chk-doc-attr.attr-code = 'CHFiscalDocSign' and chk-doc-attr.doc-code = chk-doc.doc-code no-lock no-error.
IF AVAILABLE chk-doc-attr THEN DO: 
FiscalDocSign = chk-doc-attr.attr-value.
end.


put stream OutStr-html unformatted
   '<TR>' skip
   '<TD text_wrap="true" colspan="10" style="text-align: right; font-weight: bold;"></TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: right; font-weight: bold;">' + string(itog-tot-sum,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: right; font-weight: bold;">' + string(itog-tot-base,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: right; font-weight: bold;">' + string(itog-tot-rubl,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true"></TD>' skip
   '<TD text_wrap="true" colspan="4"></TD>' skip
   '</TR>'skip 

   '<TR>' skip
   '<TD text_wrap="true" colspan="18" style="font-weight: bold;"> ФИСКАЛЬНЫЕ ДАННЫЕ </TD>' skip
   '</TR>' skip

   '<TR>' skip
   '<TD ><BR></TD>' skip
   '</TR>' skip

   '<TR>' skip
   '<TD text_wrap="true" colspan="2"> ФН </TD>' skip
   '<TD text_wrap="true" colspan="10">' NumberFN '</TD>' skip
   '</TR>' skip

   '<TR>' skip
   '<TD text_wrap="true" colspan="2"> ФД </TD>' skip
   '<TD text_wrap="true" colspan="10">' FiscalDocNumber '</TD>' skip
   '</TR>' skip

   '<TR>' skip
   '<TD text_wrap="true" colspan="2"> ФПД </TD>' skip
   '<TD text_wrap="true" colspan="10">' FiscalDocSign '</TD>' skip
   '</TR>'skip 

   '</thead>' skip  
   '</table>' skip
   '</body>' skip
   '</html>' skip   
   . 

output stream OutStr-html close.   

/*run prn-lib-reportviewer in this-procedure (*/
/*   input this-procedure                     */
/*   ,input v-file-name-rep-htm               */
/*   ,input ""                                */
/*   ) no-error.                              */
/*if error-status:error then                  */
/*do:                                         */
/*   message return-value view-as alert-box.  */
/*   return .                                 */
/*end.                                        */

run prn-lib-reportviewer-report-name in this-procedure (
   input this-procedure
   ,input v-file-name-rep-htm
   ) no-error.
if error-status:error then
do:
   message return-value view-as alert-box.
   return .
end.


PROCEDURE get-report-num :

    define output parameter p-report-num as integer no-undo .

    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.

END PROCEDURE.