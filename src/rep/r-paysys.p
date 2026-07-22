block-level on error undo, throw.
/*

$Revision: e3efe127fb4d, 2169, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:23:56 2019 +0300 $
$Workfile: r-paysys.p $
$Archive: rep/r-paysys.p $

Отчет по платежным системам

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

define variable vss-revision    as character no-undo init "$Revision: e3efe127fb4d, 2169, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:56 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-paysys.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-paysys.p $":U .
define variable vss-description as character no-undo init "Отчет по платежным системам".
{ cmp/vssrevis.i }

DEFINE TEMP-TABLE tt-promo like ub.PromoAction 
  .
       
define input parameter parparentproc           as handle           no-undo.
/*define input parameter p-sum    as decimal .*/
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
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/paramls.i  }
{ ref/gds-attr.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ str/is-min_max.i }

/* Temp-Table and Buffer definitions                                    */

    
DEFINE TEMP-TABLE tt-promo-bin NO-UNDO 
  field idAction as integer 
  field min_bin  as integer
  field max_bin  as integer
  field idName   as character
  INDEX pi idAction .

DEFINE TEMP-TABLE tt-code NO-UNDO 
  field min_code as integer
  field max_code as integer
  field CodeName as character
  INDEX pi CodeName .
              
DEFINE TEMP-TABLE tt-cash-pay like ub.cash-pay-attr 
  field obj-name as character . 

DEFINE TEMP-TABLE tt-pay-sys NO-UNDO 
  field pay-name   as character
  field pay-second as character  
  field pay-qnty   as decimal
  field pay-sum    as decimal
  INDEX pi pay-name.

define temp-table tt-doc-code no-undo
  field doc-code as character 
  field log1     as logical
  field log2     as logical
  field log3     as logical
  .

                    
define stream Out-Stream.
define stream OutStr-html.
DEFINE STREAM instream.

define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define VARIABLE v-attr-value        as character no-undo .
define variable v-obj-type          as character no-undo .
define variable v-obj-code          as integer   no-undo .
define variable v-obj-name          as character no-undo .
define variable v-period            as character no-undo .
define variable v-list-obj          as character no-undo .
define variable v-print-date        as character no-undo .
define variable v-itog-tran         as integer   no-undo .
define variable v-itog-sum          as decimal   no-undo .

define variable v-path              as character no-undo .
DEFINE VARIABLE v-full-path         as character no-undo .
DEFINE VARIABLE v-file-name         as character no-undo .
DEFINE VARIABLE v-file-name-no-ext  as character no-undo .
DEFINE VARIABLE v-file-name-ext     as character no-undo .
define variable ii                  as integer   no-undo .
define variable jj                  as integer   no-undo .
define variable kk                  as integer   no-undo .
define variable v-pay-sys           as character no-undo .
define variable v-pay-name          as character no-undo .
DEFINE variable text-string         as char      no-undo.
define variable v-payname           as character no-undo .
define variable v-nameAction        as character no-undo .

define buffer buf_chk-doc       for ub.chk-doc .
define buffer buf_chk-pay       for ub.chk-pay .
define buffer bf_chk-pay        for ub.chk-pay .
define buffer buf_cash-pay-attr for ub.cash-pay-attr .
define buffer buf_tt-code       for tt-code .
define buffer buf_tt-promo-bin  for tt-promo-bin .
define buffer buf_pay-sys       for tt-pay-sys .
define buffer buf_chk-discnt    for ub.chk-discnt .
define buffer buf_tt-promo      for tt-promo .
define buffer buf_clients       for ub.clients .
define buffer buf_code          for ub.code.
define buffer buf_PromoGoods    for ub.PromoGoods .
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
  
end.
empty temp-table tt-code .
empty temp-table tt-promo-bin .
empty temp-table tt-pay-sys .
empty temp-table tt-cash-pay .
v-itog-sum = 0 .
v-itog-tran = 0 .

/*Сбор бинов платежной системы*/
for each buf_code no-lock where buf_code.status_ = {&bef-current-status-int}:
  if num-entries (buf_code.parent,{&delim-par}) > 1 and entry(1,buf_code.parent,{&delim-par}) = "platsys" then 
  do:
    if num-entries (buf_code.code,",") > 1 then 
    do:
      do jj = 1 to num-entries (buf_code.code,","):
        v-pay-sys = entry(jj,buf_code.code) .
        if num-entries (v-pay-sys,"-") > 1 then 
        do:
          create tt-code .
          assign
            tt-code.min_code = MinInt(integer(entry(1,v-pay-sys,"-")))
            tt-code.max_code = MaxInt(integer(entry(2,v-pay-sys,"-")))
            tt-code.CodeName = buf_code.CodeName
            .
        end.  
        else 
        do:
          create tt-code .
          assign
            tt-code.min_code = MinInt(integer(v-pay-sys))
            tt-code.max_code = MaxInt(integer(v-pay-sys))
            tt-code.CodeName = buf_code.CodeName
            .
        end.  
      end.  
    end.   
    else 
    do:
      if num-entries (buf_code.code,"-") > 1 then 
      do:
        create tt-code .
        assign
          tt-code.min_code = MinInt(integer(entry(1,buf_code.code,"-")))
          tt-code.max_code = MaxInt(integer(entry(2,buf_code.code,"-")))
          tt-code.CodeName = buf_code.CodeName
          .
      end.  
      else 
      do:
        create tt-code .
        assign
          tt-code.min_code = MinInt(integer(buf_code.code))
          tt-code.max_code = MaxInt(integer(buf_code.code))
          tt-code.CodeName = buf_code.CodeName
          .
      end.      
    end.  
  end.  
end.
/*Сбор бинов акций*/
for each buf_tt-promo no-lock where buf_tt-promo.end-date >= x-Date-Start and buf_tt-promo.beg-date <= x-Date-End:
  v-nameAction = buf_tt-promo.nameAction .
  for each buf_PromoGoods no-lock where buf_PromoGoods.type = 5 and buf_PromoGoods.idAction = buf_tt-promo.id and buf_PromoGoods.db-num = buf_tt-promo.db-num:
    if num-entries (buf_PromoGoods.NameSet,"-") > 1 then 
    do:
      create tt-promo-bin .
      assign
        tt-promo-bin.min_bin  = MinInt(integer(entry(1,buf_PromoGoods.NameSet,"-")))
        tt-promo-bin.max_bin  = MaxInt(integer(entry(2,buf_PromoGoods.NameSet,"-")))
        tt-promo-bin.idAction = buf_PromoGoods.idAction
        tt-promo-bin.idName   = v-nameAction
        .
    end.  
    else 
    do:
      create tt-promo-bin .
      assign
        tt-promo-bin.min_bin  = MinInt(integer(buf_PromoGoods.NameSet))
        tt-promo-bin.max_bin  = MaxInt(integer(buf_PromoGoods.NameSet))
        tt-promo-bin.idAction = buf_PromoGoods.idAction
        tt-promo-bin.idName   = v-nameAction
        .
    end.      
  end.  
end.

DEFINE VARIABLE v-dop   AS character NO-UNDO .
DEFINE VARIABLE v-value AS character NO-UNDO.
DEFINE VARIABLE v-type  AS character NO-UNDO.
/*заполнение таблицы всех платежей с атрибутом группа платежей: карта*/   

for each buf_cash-pay-attr no-lock where buf_cash-pay-attr.attr-code = "cash-prop"
  and buf_cash-pay-attr.attr-value = "2",
  first ub.cash-pay no-lock where ub.cash-pay.cdpay-code = buf_cash-pay-attr.cdpay-code and ub.cash-pay.curr-code = buf_cash-pay-attr.curr-code:
  create tt-cash-pay .
  buffer-copy buf_cash-pay-attr to tt-cash-pay .
  tt-cash-pay.obj-name = ub.cash-pay.obj-name .
  
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
      and buf_chk-doc.chk-type = integer({&rcpt-sale})
      and buf_chk-doc.out-code <> ?:

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
      and buf_chk-doc.chk-type = integer({&rcpt-sale})
      and buf_chk-doc.out-code <> ?:
      run report .
    end.  
  end.  
end.

/*Общие данные*/

procedure report:
  for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-doc.doc-code,
    first tt-cash-pay no-lock where tt-cash-pay.curr-code = buf_chk-pay.curr-code and tt-cash-pay.cdpay-code = buf_chk-pay.pay-code:
    find first tt-doc-code no-lock where tt-doc-code.doc-code = buf_chk-pay.doc-code no-error .
    if not available (tt-doc-code) then 
    do:
      create tt-doc-code .
      assign
        tt-doc-code.doc-code = buf_chk-pay.doc-code
        .
    end.  
    find first buf_tt-code no-lock where substring (buf_chk-pay.pay-card,1,6) >= string (buf_tt-code.min_code) and substring (buf_chk-pay.pay-card,1,6) <= string (buf_tt-code.max_code) no-error .
    if available (buf_tt-code) then 
    do:
      v-pay-name = buf_tt-code.CodeName .
    end.
    else v-pay-name = "Прочие" .  
    find first buf_pay-sys exclusive-lock where buf_pay-sys.pay-name = v-pay-name no-error .
    if not available (buf_pay-sys) then 
    do:
      create buf_pay-sys .
      assign
        buf_pay-sys.pay-second = v-pay-name
        buf_pay-sys.pay-name   = v-pay-name
        buf_pay-sys.pay-qnty   = 1
        buf_pay-sys.pay-sum    = buf_chk-pay.tot-sum
        .
      tt-doc-code.log1 = yes.
    end.
    else 
    do:
      assign
        buf_pay-sys.pay-sum = buf_pay-sys.pay-sum + buf_chk-pay.tot-sum
        .    
      if tt-doc-code.log1 = no then buf_pay-sys.pay-qnty = buf_pay-sys.pay-qnty + 1 .
      tt-doc-code.log1 = yes .
    end.    
    for first buf_tt-promo-bin no-lock where substring (buf_chk-pay.pay-card,1,6) >= string (buf_tt-promo-bin.min_bin) and substring (buf_chk-pay.pay-card,1,6) >= string (buf_tt-promo-bin.max_bin):
      find first buf_pay-sys exclusive-lock where buf_pay-sys.pay-name = "Премиальные карты " + v-pay-name no-error .
      if available (buf_pay-sys) then 
      do:
        assign
          buf_pay-sys.pay-sum = buf_pay-sys.pay-sum + buf_chk-pay.tot-sum
          . 
        if tt-doc-code.log2 = no then buf_pay-sys.pay-qnty = buf_pay-sys.pay-qnty + 1 .
        tt-doc-code.log2 = yes .
      end.
      else 
      do:
        create buf_pay-sys .
        assign
          buf_pay-sys.pay-second = v-pay-name
          buf_pay-sys.pay-name   = "Премиальные карты " + v-pay-name
          buf_pay-sys.pay-qnty   = 1
          buf_pay-sys.pay-sum    = buf_chk-pay.tot-sum
          .        
        tt-doc-code.log2 = yes .
      end.    
      /*      if p-sum <> ? and p-sum <> 0 then*/
      /*      do:                              */
      /*        if buf_chk-pay.tot-sum > p-sum     */
      /*        or buf_chk-pay.tot-sum = p-sum then*/
      /*        do:                                */
      for each buf_chk-discnt no-lock where buf_chk-discnt.doc-code = buf_chk-doc.doc-code and buf_chk-discnt.promo-id = string(tt-promo-bin.idAction) and buf_chk-discnt.record-type = 0 :
        /*            find first buf_pay-sys exclusive-lock where buf_pay-sys.pay-name = string("Премиальные карты " + v-pay-name + " более " + string(p-sum) + "р.") no-error .*/
        find first buf_pay-sys exclusive-lock where buf_pay-sys.pay-name = tt-promo-bin.idName and buf_pay-sys.pay-second = v-pay-name no-error .
        if available (buf_pay-sys) then 
        do:
          assign
            buf_pay-sys.pay-sum = buf_pay-sys.pay-sum + buf_chk-pay.tot-sum
            .      
          if tt-doc-code.log3 = no then buf_pay-sys.pay-qnty = buf_pay-sys.pay-qnty + 1 .
          tt-doc-code.log3 = yes .  
        end.
        else 
        do:
          create buf_pay-sys .
          assign
            buf_pay-sys.pay-second = v-pay-name
            buf_pay-sys.pay-name   = tt-promo-bin.idName
            buf_pay-sys.pay-qnty   = 1
            buf_pay-sys.pay-sum    = buf_chk-pay.tot-sum
            .
        end.    
        for each bf_chk-pay no-lock where bf_chk-pay.doc-code = buf_chk-pay.doc-code and bf_chk-pay.tot-sum < 0 : 
          buf_pay-sys.pay-sum = buf_pay-sys.pay-sum + bf_chk-pay.tot-sum .
        end.

      /*          end.*/
      /*        end.*/
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
  '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
  '<thead>' skip
  .
put stream OutStr-html unformatted
  '<tr>' skip
  '<td style="width: 100px;"></td>' skip
  '<td style="width: 260px;"></td>' skip
  '<td style="width: 120px;"></td>' skip
  '<td style="width: 160px;"></td>' skip
  '</tr>' skip
  .
                        
 
put stream OutStr-html unformatted
  '<TR><TD colspan="4"></TD></TR>' skip

  '<TR>' skip
  '<TD colspan="4" style="font-weight: bold;">Отчет по платежным системам</TD>' skip
  '</TR>'skip
                              
  '<TR>' skip
  '<TD colspan="4">' + v-period + '</TD>' skip
  '</TR>'skip

  '<TR>' skip
  '<TD colspan="4">' + v-obj-name + '</TD>' skip
  '</TR>'skip

  '<TR>' skip
  '<TD colspan="4">Выбор объекта:</TD>' skip
  '</TR>'skip

  '<TR>' skip
  '<TD colspan="4">' + "АЗК №" + v-list-obj + " маг" + '</TD>' skip
  '</TR>'skip

  '<TR>' skip
  '<TD colspan="4">' + v-print-date + '</TD>' skip
  '</TR>'skip

  '</thead>' skip
  '<tbody>' skip
  .
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" style="text-align: center;">Внутренний код платежной системы</TD>' skip
  '<TD text_wrap="true" style="text-align: center;">Название платежной системы</TD>' skip
  '<TD text_wrap="true" style="text-align: center;">Количество транзакций</TD>' skip
  '<TD text_wrap="true" style="text-align: center;">Сумма оплаты</TD>' skip
  '</TR>'skip       
                    
  .
ii = 0 .
for each buf_pay-sys where buf_pay-sys.pay-name = buf_pay-sys.pay-second:
  ii = ii + 1 .
  kk = 0 .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(ii) + '</TD>' skip
    '<TD text_wrap="true">' + string(buf_pay-sys.pay-name) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: right;">' + string(buf_pay-sys.pay-qnty) + '</TD>' skip
    '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_pay-sys.pay-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_pay-sys.pay-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
    '</TR>'skip     
    .
  v-itog-sum = v-itog-sum + buf_pay-sys.pay-sum .
  v-itog-tran = v-itog-tran + buf_pay-sys.pay-qnty .
  v-pay-name = "" .
  for first tt-pay-sys where tt-pay-sys.pay-second = buf_pay-sys.pay-name and tt-pay-sys.pay-second <> tt-pay-sys.pay-name and tt-pay-sys.pay-name begins "Премиальные":
    v-payname = tt-pay-sys.pay-name .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: right;">в том числе</TD>' skip
      '<TD text_wrap="true">' + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + string(tt-pay-sys.pay-name) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right;">' + string(tt-pay-sys.pay-qnty) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-pay-sys.pay-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-pay-sys.pay-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '</TR>'skip     
      .
  end.     
  for each tt-pay-sys where tt-pay-sys.pay-second = buf_pay-sys.pay-name and tt-pay-sys.pay-second <> tt-pay-sys.pay-name and tt-pay-sys.pay-name <> v-payname:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: right;"></TD>' skip
      '<TD text_wrap="true">' + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + string(tt-pay-sys.pay-name) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right;">' + string(tt-pay-sys.pay-qnty) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-pay-sys.pay-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-pay-sys.pay-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '</TR>'skip     
      .
  end.
end.

put stream OutStr-html unformatted
  '<TR>' skip
  '<TD colspan="2" text_wrap="true" style="text-align: center; font-weight: bold;">Итого по банковским картам:</TD>' skip
  '<TD text_wrap="true" style="text-align: right;">' + string (v-itog-tran) + '</TD>' skip
  '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-itog-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon (v-itog-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
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
