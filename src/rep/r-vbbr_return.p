block-level on error undo, throw.
/*

$Revision: c6449d82dd2b, 2155, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:23:55 2019 +0300 $
$Workfile: r-vbbr_return.p $
$Archive: rep/r-vbbr_return.p $

Отчет для контроля возвратных операций

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

define variable vss-revision    as character no-undo init "$Revision: c6449d82dd2b, 2155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:55 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-vbbr_return.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-vbbr_return.p $":U .
define variable vss-description as character no-undo init "Отчет для контроля возвратных операций".
{ cmp/vssrevis.i }

DEFINE TEMP-TABLE tt-promo like ub.PromoAction .

DEFINE TEMP-TABLE tt-podarki NO-UNDO 
  field obj-code    as integer
  field date_sale   as character
  field chk-num     as integer
  field sum_sale    as decimal
  field date_return as character
  field chk-num2    as integer
  field sum_return  as decimal 
  field tot-sum     like ub.chk-doc.tot-doc
  field doc-code    as character
  INDEX pi doc-code .
       

define input parameter parparentproc           as handle           no-undo.
define input parameter table for tt-promo .


{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i      }
{ cmp/r-pril.i   }
{ ref/cp-attr.i }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ rep/w-rep.i    }
{ rep/fmtcli.i   }
{ rep/torgconf.i }
{ str/getctxtp.i def }
{ gbl/paramls.i  }
{ ref/gds-attr.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }

/* Temp-Table and Buffer definitions                                    */
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }        
                  
define stream Out-Stream.
define stream OutStr-html.

DEFINE TEMP-TABLE tt-cash-pay like ub.cash-pay-attr . 

define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define VARIABLE v-attr-value        as character no-undo .
define variable v-obj-type          as character no-undo .
define variable v-obj-code          as integer   no-undo .
define variable v-obj-name          as character no-undo .
define variable v-period            as character no-undo .
define variable v-list-obj          as character no-undo .
define variable v-print-date        as character no-undo .
define variable v-doc-num2          as character no-undo .

define buffer buf_chk-doc   for ub.chk-doc .
define buffer bf_chk-doc   for ub.chk-doc .
define buffer buf_clients   for ub.clients .
define buffer buf_chk-disnt for ub.chk-discnt .
define buffer buf_chk-gds   for ub.chk-gds .
define buffer buf_bar-code  for ub.bar-code .
define buffer buf_goods     for ub.goods .
define buffer buf_podarki   for tt-podarki .
define buffer buf_cash-pay-attr for ub.cash-pay-attr .
define buffer buf_chk-pay       for ub.chk-pay .

do
  on error undo, return error return-value
  :

  find first obj-list no-error .
  if not available obj-list then 
  do:
    message
      "Не указан объект для формирования отчета!"
      view-as alert-box error.
    undo, return error.
  end.
  
  DEFINE VARIABLE v-dop   AS character NO-UNDO .
  DEFINE VARIABLE v-value AS character NO-UNDO.
  DEFINE VARIABLE v-type  AS character NO-UNDO.
  for each buf_cash-pay-attr no-lock where buf_cash-pay-attr.attr-code = "cash-prop"
    and buf_cash-pay-attr.attr-value = "2":
    create tt-cash-pay .
    buffer-copy buf_cash-pay-attr to tt-cash-pay .
  end.
  /*Данные для шапки*/
  /*Период*/
  if x-TOG-Shift then 
  do:
    v-period = "Смены с " + string (x-Shift-Start) + " по " + string (x-Shift-End) + " За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
  end.
  else 
  do:
    v-period = "За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
  end.      
  /*Название объекта*/
  run clients-write(INPUT v-cntxt-host-code-obj, INPUT {&cmp}, OUTPUT v-obj-name) no-error .    
  /*Дата и время печати*/
  DEFINE VARIABLE v-today as date    no-undo .
  DEFINE VARIABLE v-time  as integer no-undo .
  run cur-time in this-procedure (
    output v-today
    , output v-time
    ).
  v-print-date = "Дата печати: " + string (v-today,"99.99.9999") + ", время: " + string(truncate (v-time / 3600, 0)) + ":" + string((v-time modulo 3600) / 60,"99")  + ":" + string((v-time modulo 3600) / 360,"99").     

  for each obj-list no-lock:
    if v-list-obj = "" then v-list-obj = string(obj-list.obj-code).
    else v-list-obj = v-list-obj + ", " + string(obj-list.obj-code).
  
    if x-TOG-Shift then 
    do:
    
      for each buf_chk-doc no-lock 
        where buf_chk-doc.obj-code = obj-list.obj-code 
        and buf_chk-doc.obj-type = obj-list.obj-type
        and buf_chk-doc.shift-date >= x-Date-Start 
        and buf_chk-doc.shift-date <= x-Date-End
        and buf_chk-doc.out-code <> ?
        and  (buf_chk-doc.chk-type = integer({&rcpt-return})
        or buf_chk-doc.chk-type = integer({&rcpt-return-write-off})):

        if (buf_chk-doc.shift-date = X-date-Start)
          and (buf_chk-doc.shift-num < x-Shift-Start) then next. 
        if (buf_chk-doc.shift-date = X-date-End)
          and (buf_chk-doc.shift-num > x-Shift-End) then next.
        run report .
      end.
    end.
    else 
    do:
      for each buf_chk-doc no-lock 
        where buf_chk-doc.obj-code = obj-list.obj-code 
        and buf_chk-doc.obj-type = obj-list.obj-type
        and buf_chk-doc.chk-date >= x-Date-Start 
        and buf_chk-doc.chk-date <= x-Date-End
        and buf_chk-doc.out-code <> ?
        and  (buf_chk-doc.chk-type = integer({&rcpt-return})
        or buf_chk-doc.chk-type = integer({&rcpt-return-write-off}))  :
        run report .
      end.  
    end.  
  end.

/*Общие данные*/

procedure report:
for each tt-promo, each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-doc.doc-code,
first tt-cash-pay no-lock where tt-cash-pay.curr-code = buf_chk-pay.curr-code and tt-cash-pay.cdpay-code = buf_chk-pay.pay-code:
      if num-entries (buf_chk-doc.doc-num2,":") > 1 then 
      do:
        v-doc-num2 = entry(1, buf_chk-doc.doc-num2,":") .
      end. 
      else v-doc-num2 = buf_chk-doc.doc-num2 . 

    for last bf_chk-doc no-lock where bf_chk-doc.chk-num = integer(v-doc-num2) and bf_chk-doc.obj-code = buf_chk-doc.obj-code
    and bf_chk-doc.obj-type = buf_chk-doc.obj-type and bf_chk-doc.z-number = buf_chk-doc.z-number
    and bf_chk-doc.pay-desk = buf_chk-doc.pay-desk and bf_chk-doc.chk-type = integer({&rcpt-sale}) by bf_chk-doc.chk-date:
	/*and bf_chk-doc.chk-date = buf_chk-doc.chk-date,*/
  for first buf_chk-disnt no-lock where buf_chk-disnt.doc-code = bf_chk-doc.doc-code
    and buf_chk-disnt.promo-id = string(tt-promo.id) and buf_chk-disnt.record-type = 0:

        create tt-podarki .
        assign
          tt-podarki.obj-code = buf_chk-doc.obj-code
          tt-podarki.date_sale    = string(bf_chk-doc.chk-date,"99.99.9999") + " " + string(truncate (bf_chk-doc.chk-time / 3600, 0)) + ":" + string((bf_chk-doc.chk-time modulo 3600) / 60,"99")
          tt-podarki.chk-num = bf_chk-doc.chk-num
          tt-podarki.doc-code = buf_chk-doc.doc-code
          tt-podarki.sum_sale = bf_chk-doc.netto
          tt-podarki.date_return = string(buf_chk-doc.chk-date,"99.99.9999") + " " + string(truncate (buf_chk-doc.chk-time / 3600, 0)) + ":" + string((buf_chk-doc.chk-time modulo 3600) / 60,"99")
          tt-podarki.chk-num2 = buf_chk-doc.chk-num
          tt-podarki.sum_return = buf_chk-doc.netto
          tt-podarki.tot-sum  = bf_chk-doc.netto + buf_chk-doc.netto
          .      
      end.  
    end.  
    end.
  
end procedure.      
   
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
    '<tr>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '</tr>' skip
    .
                        
 
  put stream OutStr-html unformatted
    '<TR><TD colspan="8"></TD></TR>' skip
    '<TR>' skip
    '<TD colspan="8" style="font-weight: bold;">Отчет для контроля возвратных операций</TD>' skip
    '</TR>'skip
                                
    '<TR>' skip
    '<TD colspan="8">' + v-period + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="8">' + v-obj-name + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="8">Выбор объекта:</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="8">' + "АЗК №" + v-list-obj + " маг" + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="8">' + v-print-date + '</TD>' skip
    '</TR>'skip

    '</thead>' skip
    '<tbody>' skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">Номер АЗК</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Дата и время покупки</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Номер чека продажи</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Сумма чека продажи</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Дата и время чека возврата</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Номер чека возврата</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Сумма чека возврата</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Итоговая сумма с учетом возврата</TD>' skip
    '</TR>'skip       
                    
    .
    
    
  for each buf_podarki:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true">' + string(buf_podarki.obj-code) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: left;">' + string(buf_podarki.date_sale) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(buf_podarki.chk-num) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_podarki.sum_sale,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_podarki.sum_sale,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: left;">' + string(buf_podarki.date_return) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(buf_podarki.chk-num2) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_podarki.sum_return,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_podarki.sum_return,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_podarki.tot-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_podarki.tot-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '</TR>'skip     
      .
  end.


  put stream OutStr-html unformatted

    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
                            
  output stream OutStr-html close.     
                                                                                                                
  run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).


PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.


procedure clients-write:
    
  DEFINE input PARAMETER   p-obj-code      as integer      no-undo .
  DEFINE INPUT PARAMETER   p-obj-type      as character    no-undo .
  DEFINE OUTPUT PARAMETER  p-obj-name      as character    no-undo .
        
  find first buf_clients no-lock where buf_clients.obj-code = p-obj-code
    and buf_clients.obj-type = p-obj-type no-error .
  if AVAILABLE buf_clients then 
  do:
    p-obj-name = buf_clients.obj-name .
  end.     
end.                                            
end. 
