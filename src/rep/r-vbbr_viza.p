block-level on error undo, throw.
/*

$Revision: 2d9a05598e65, 2372, rls $
$Author: EShklyar $
$Date: Ср июн 10 21:13:42 2020 +0300 $
$Workfile: r-vbbr_viza.p $
$Archive: rep/r-vbbr_viza.p $

Отчет для сверки ВБРР-Виза

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

define variable vss-revision    as character no-undo init "$Revision: 2d9a05598e65, 2372, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:42 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-vbbr_viza.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-vbbr_viza.p $":U .
define variable vss-description as character no-undo init "Отчет для сверки ВБРР-Виза".

{ cmp/vssrevis.i }

DEFINE TEMP-TABLE tt-promo like ub.PromoAction .

define input parameter parparentproc as handle no-undo .
define input parameter table for tt-promo .
define input parameter p-vozvrat  as logical no-undo .

DEFINE TEMP-TABLE tt-podarki NO-UNDO 
  field gds-code as integer
  field date_    as character
  field obj-code as integer
  field obj-name as character
  field d-card   as character
  field gds-name as character
  field price    like ub.chk-gds.price-base
  field tot-sum  like ub.chk-doc.tot-doc
  field doc-code as character
  field qnty     as integer
  field sum-sum  as decimal 
  INDEX pi doc-code .
       


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
define variable v-itog-sum          as decimal   no-undo .
define variable v-itog-qnty         as decimal   no-undo .
define variable v-itog-sum-sum      as decimal   no-undo .
define variable v-report-name       as character no-undo .
define variable v-doc-num2          as character no-undo .

define buffer buf_chk-doc   for ub.chk-doc .
define buffer bf_chk-doc        for ub.chk-doc .
define buffer buf_clients       for ub.clients .
define buffer buf_chk-discnt    for ub.chk-discnt .
define buffer bf_chk-discnt     for ub.chk-discnt .
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
      case p-vozvrat :
        when yes then 
          do:
            for each buf_chk-doc no-lock 
              where buf_chk-doc.obj-code = obj-list.obj-code 
              and buf_chk-doc.obj-type = obj-list.obj-type
              and buf_chk-doc.shift-date >= x-Date-Start 
              and buf_chk-doc.shift-date <= x-Date-End
              and buf_chk-doc.out-code <> ?:

              if (buf_chk-doc.shift-date = X-date-Start)
                and (buf_chk-doc.shift-num < x-Shift-Start) then next. 
              if (buf_chk-doc.shift-date = X-date-End)
                and (buf_chk-doc.shift-num > x-Shift-End) then next.
              if buf_chk-doc.chk-type = integer({&rcpt-return})
                or buf_chk-doc.chk-type = integer({&rcpt-return-write-off}) then 
              do:                
                run report-vozvrat .
              end.
              else run report .
            end.
          end.
        when no then 
          do:
            for each buf_chk-doc no-lock
              where buf_chk-doc.obj-code = obj-list.obj-code
              and buf_chk-doc.obj-type = obj-list.obj-type
              and buf_chk-doc.shift-date >= x-Date-Start
              and buf_chk-doc.shift-date <= x-Date-End
              and buf_chk-doc.out-code <> ?
              and buf_chk-doc.chk-type <> integer({&rcpt-return})
              and buf_chk-doc.chk-type <> integer({&rcpt-return-write-off}):

              if (buf_chk-doc.shift-date = X-date-Start)
                and (buf_chk-doc.shift-num < x-Shift-Start) then next.
              if (buf_chk-doc.shift-date = X-date-End)
                and (buf_chk-doc.shift-num > x-Shift-End) then next.
              run report .
            end.
          end.
      end case.
    end.
    else 
    do:
      case p-vozvrat :
        when yes then 
          do:
            for each buf_chk-doc no-lock 
              where buf_chk-doc.obj-code = obj-list.obj-code 
              and buf_chk-doc.obj-type = obj-list.obj-type
              and buf_chk-doc.chk-date >= x-Date-Start 
              and buf_chk-doc.chk-date <= x-Date-End
              and buf_chk-doc.out-code <> ?:

              /*              if (buf_chk-doc.shift-date = X-date-Start)              */
              /*                and (buf_chk-doc.shift-num < x-Shift-Start) then next.*/
              /*              if (buf_chk-doc.shift-date = X-date-End)                */
              /*                and (buf_chk-doc.shift-num > x-Shift-End) then next.  */
              if buf_chk-doc.chk-type = integer({&rcpt-return})
                or buf_chk-doc.chk-type = integer({&rcpt-return-write-off}) then 
              do:                
                run report-vozvrat .
              end.
              else run report .
            end.
          end.
        when no then 
          do:
            for each buf_chk-doc no-lock 
              where buf_chk-doc.obj-code = obj-list.obj-code 
              and buf_chk-doc.obj-type = obj-list.obj-type
              and buf_chk-doc.chk-date >= x-Date-Start 
              and buf_chk-doc.chk-date <= x-Date-End
              and buf_chk-doc.out-code <> ?
              and buf_chk-doc.chk-type <> integer({&rcpt-return})
              and buf_chk-doc.chk-type <> integer({&rcpt-return-write-off}):

              /*              if (buf_chk-doc.shift-date = X-date-Start)              */
              /*                and (buf_chk-doc.shift-num < x-Shift-Start) then next.*/
              /*              if (buf_chk-doc.shift-date = X-date-End)                */
              /*                and (buf_chk-doc.shift-num > x-Shift-End) then next.  */
              run report .
            end.
          end.
      end case.

    end.  
  end.

/*Общие данные*/
procedure report-vozvrat:
  for each tt-promo,
   each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-doc.doc-code,
     first tt-cash-pay no-lock where tt-cash-pay.curr-code = buf_chk-pay.curr-code and tt-cash-pay.cdpay-code = buf_chk-pay.pay-code:
         if num-entries (buf_chk-doc.doc-num2,":") > 1 then 
    do:
      v-doc-num2 = entry(1, buf_chk-doc.doc-num2,":") .
    end. 
    else v-doc-num2 = buf_chk-doc.doc-num2 . 
   for first bf_chk-discnt no-lock where bf_chk-discnt.doc-code = buf_chk-doc.doc-code
    and bf_chk-discnt.promo-id = string(tt-promo.id) and bf_chk-discnt.record-type = 0,
 last bf_chk-doc no-lock where bf_chk-doc.chk-num = integer(v-doc-num2) and bf_chk-doc.obj-code = buf_chk-doc.obj-code
      and bf_chk-doc.obj-type = buf_chk-doc.obj-type and bf_chk-doc.z-number = buf_chk-doc.z-number
      and bf_chk-doc.pay-desk = buf_chk-doc.pay-desk and bf_chk-doc.chk-type = integer({&rcpt-sale}):    
    for first buf_chk-gds no-lock where buf_chk-gds.doc-code = bf_chk-discnt.doc-code and buf_chk-gds.line-num = bf_chk-discnt.line-num,
      first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code,
      first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code:
        find last ub.price-list no-lock where ub.price-list.obj-code = buf_chk-doc.obj-code
        and ub.price-list.obj-type = buf_chk-doc.obj-type
        and ub.price-list.b-code = buf_bar-code.b-code no-error .
         
        create tt-podarki .
        if length (buf_chk-pay.pay-card) = 9 then tt-podarki.d-card = "XXXXX" + substring (buf_chk-pay.pay-card,5,4).
        else tt-podarki.d-card = substring(buf_chk-pay.pay-card,1,6) + "XXXXXX" + substring (buf_chk-pay.pay-card,13,4).
          assign
/*          tt-podarki.d-card = tt-promo.nameAction*/
          tt-podarki.date_  = string(buf_chk-doc.chk-date,"99.99.9999") + " " + string(truncate (buf_chk-doc.chk-time / 3600, 0)) + ":" + string((buf_chk-doc.chk-time modulo 3600) / 60,"99")
          tt-podarki.doc-code = buf_chk-doc.doc-code
          tt-podarki.gds-code = buf_goods.gds-code
          tt-podarki.gds-name = buf_goods.gds-name
          tt-podarki.obj-code = buf_chk-doc.obj-code
          tt-podarki.price    = if available (ub.price-list) then ub.price-list.price-sale else 0
          tt-podarki.tot-sum  = buf_chk-doc.tot-doc
          tt-podarki.qnty     = buf_chk-gds.doc-qnty * -1
          tt-podarki.sum-sum  = if available (ub.price-list) then ub.price-list.price-sale * -1 else 0
        .      
        run clients-write(INPUT buf_chk-doc.obj-code, INPUT buf_chk-doc.obj-type, OUTPUT tt-podarki.obj-name) no-error .
          assign
          v-itog-qnty    = v-itog-qnty + tt-podarki.qnty
          v-itog-sum     = v-itog-sum + tt-podarki.tot-sum
          v-itog-sum-sum = v-itog-sum-sum + tt-podarki.sum-sum
          .  
    end.  
  end.  
end.
end procedure.   

procedure report:
  for each tt-promo,
   each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-doc.doc-code and buf_chk-pay.tot-sum > 0,
   first tt-cash-pay no-lock where tt-cash-pay.curr-code = buf_chk-pay.curr-code and tt-cash-pay.cdpay-code = buf_chk-pay.pay-code:
   for each buf_chk-discnt no-lock where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
    and buf_chk-discnt.promo-id = string(tt-promo.id) and buf_chk-discnt.record-type = 0:
    for first buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-discnt.doc-code and buf_chk-gds.line-num = buf_chk-discnt.line-num,
      first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code,
      first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code:
        find last ub.price-list no-lock where ub.price-list.obj-code = buf_chk-doc.obj-code
        and ub.price-list.obj-type = buf_chk-doc.obj-type
        and ub.price-list.b-code = buf_bar-code.b-code no-error .
         
        create tt-podarki .
        if length (buf_chk-pay.pay-card) = 9 then tt-podarki.d-card = "XXXXX" + substring (buf_chk-pay.pay-card,5,4).
        else tt-podarki.d-card = substring(buf_chk-pay.pay-card,1,6) + "XXXXXX" + substring (buf_chk-pay.pay-card,13,4).
          assign
/*          tt-podarki.d-card = tt-promo.nameAction*/
          tt-podarki.date_  = string(buf_chk-doc.chk-date,"99.99.9999") + " " + string(truncate (buf_chk-doc.chk-time / 3600, 0)) + ":" + string((buf_chk-doc.chk-time modulo 3600) / 60,"99")
          tt-podarki.doc-code = buf_chk-doc.doc-code
          tt-podarki.gds-code = buf_goods.gds-code
          tt-podarki.gds-name = buf_goods.gds-name
          tt-podarki.obj-code = buf_chk-doc.obj-code
          tt-podarki.price    = if available (ub.price-list) then ub.price-list.price-sale else 0
          tt-podarki.tot-sum  = buf_chk-doc.tot-doc
          tt-podarki.qnty     = buf_chk-gds.doc-qnty
          tt-podarki.sum-sum  = if available (ub.price-list) then ub.price-list.price-sale else 0
        .      
        run clients-write(INPUT buf_chk-doc.obj-code, INPUT buf_chk-doc.obj-type, OUTPUT tt-podarki.obj-name) no-error .
                assign
          v-itog-qnty    = v-itog-qnty + tt-podarki.qnty
          v-itog-sum     = v-itog-sum + tt-podarki.tot-sum
          v-itog-sum-sum = v-itog-sum-sum + tt-podarki.sum-sum
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
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 260px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '</tr>' skip
    .
                        
  if p-vozvrat then v-report-name = "Отчет для сверки ВБРР-Виза c возвратами" .
  else v-report-name = "Отчет для сверки ВБРР-Виза без возвратов" .

  put stream OutStr-html unformatted
    '<TR><TD colspan="9"></TD></TR>' skip
    '<TR>' skip
    '<TD colspan="9" style="font-weight: bold;">' + v-report-name + '</TD>' skip
    '</TR>'skip
                                
    '<TR>' skip
    '<TD colspan="9">' + v-period + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="9">' + v-obj-name + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="9">Выбор объекта:</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="9">' + "АЗК №" + v-list-obj + " маг" + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="9">' + v-print-date + '</TD>' skip
    '</TR>'skip

    '</thead>' skip
    '<tbody>' skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">Дата и время покупки</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Номер АЗС</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Номер карты или Range token</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Код товара подарка</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Название подарка</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Розничная цена</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Сумма чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Количество подарков</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Стоимость подарков</TD>' skip
    '</TR>'skip       
                    
    .
  for each buf_podarki:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(buf_podarki.date_) + '</TD>' skip
      '<TD text_wrap="true">' + string(buf_podarki.obj-name) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right;">' + string(buf_podarki.d-card) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right;">' + string(buf_podarki.gds-code) + '</TD>' skip
      '<TD text_wrap="true">' + string(buf_podarki.gds-name) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_podarki.price,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_podarki.price,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_podarki.tot-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_podarki.tot-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_podarki.qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_podarki.qnty,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_podarki.sum-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_podarki.sum-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '</TR>'skip     
      .
  end.
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true" style="text-align: right;"></TD>' skip
    '<TD text_wrap="true" style="text-align: right;"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true" style="font-weight: bold;">Итого:</TD>' skip
    '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-itog-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: bold;">' + fnc-convert-dot-to-colon(v-itog-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
    '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-itog-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: bold;">' + fnc-convert-dot-to-colon(v-itog-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' skip
    '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-itog-sum-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: bold;">' + fnc-convert-dot-to-colon(v-itog-sum-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
    '</TR>'skip     
    .


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
