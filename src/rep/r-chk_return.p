block-level on error undo, throw.
/*

$Revision: 5d506dbcaae6, 2911, rls $
$Author: EShklyar $
$Date: Пн ноя 22 19:49:14 2021 +0300 $
$Workfile: r-chk_return.p $
$Archive: rep/r-chk_return.p $

Очет по возвратным операциям

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-itog                   as logical                  no-undo .
define input parameter p-oplat                  as character                no-undo .

define variable vss-revision    as character no-undo init "$Revision: 5d506dbcaae6, 2911, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:14 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-chk_return.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-chk_return.p $":U .
define variable vss-description as character no-undo init "Очет по возвратным операциям".
{ cmp/vssrevis.i }

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

DEFINE TEMP-TABLE tt-return
  field obj-code as integer
  field obj-type as character
  field obj-name as character
  field date_    as date
  field time_    as integer
  field chk-num  as integer
  field doc-code as character
  field chk-type as character
  field cash-num as integer
  field fio      as character
  Index pi obj-code obj-type doc-code
  . 

DEFINE TEMP-TABLE tt-gds-pay
  field obj-code  as integer
  field obj-type  as character
  field doc-code  as character
  field gds-code  as integer
  field gds-name  as character
  field price     as decimal
  field qnty      as decimal
  field sum_      as decimal
  field d-card    as character
  field line-num  as integer
  field pay-type  as character
  field p-card    as character
  field pay_qnty  as decimal
  field sum_total as decimal
  field print     as integer
  field sbprrn    as character
  field sbpstat   as character
  Index pi obj-code obj-type doc-code line-num
  . 

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
define variable v-name-chk-type     as character no-undo .
define variable v-gds-line          as logical   no-undo .
define variable v-pay-line          as logical   no-undo .
define variable ii                  as integer   no-undo .
define variable jj                  as integer   no-undo .

define buffer buf_chk-doc      for ub.chk-doc .
define buffer bf_chk-doc       for ub.chk-doc .
define buffer buf_clients      for ub.clients .
define buffer buf_chk-disnt    for ub.chk-discnt .
define buffer buf_chk-pay-attr for ub.chk-pay-attr .
define buffer buf_chk-pay      for ub.chk-pay .
define buffer buf_chk-gds      for ub.chk-gds .
define buffer buf_chk-gds-pay  for ub.chk-gds-pay .
define buffer buf_goods        for ub.goods .
define buffer buf_bar-code     for ub.bar-code .
define buffer buf_cash-pay     for ub.cash-pay .

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
  ii = 0 .
  jj = 0 .
  find first tt-return where tt-return.doc-code = buf_chk-doc.doc-code and tt-return.obj-code = buf_chk-doc.obj-code
    and tt-return.obj-type = buf_chk-doc.obj-type no-error .
  if not available (tt-return) then 
  do:
    create tt-return .
    assign
      tt-return.doc-code = buf_chk-doc.doc-code
      tt-return.obj-code = buf_chk-doc.obj-code
      tt-return.obj-type = buf_chk-doc.obj-type
      tt-return.cash-num = buf_chk-doc.pay-desk
      tt-return.chk-num  = buf_chk-doc.chk-num
      tt-return.date_    = buf_chk-doc.chk-date
      tt-return.time_    = buf_chk-doc.chk-time
      .
    run ConvertStr-chk-type(INPUT buf_chk-doc.chk-type,OUTPUT tt-return.chk-type) .
    run clients-write(INPUT buf_chk-doc.cashier-psn-code,INPUT {&prs},OUTPUT tt-return.fio) .
    run clients-write(INPUT buf_chk-doc.obj-code,INPUT buf_chk-doc.obj-type,OUTPUT tt-return.obj-name) .          
  end. 
  for each buf_chk-gds no-lock where buf_chk-gds.doc-code = tt-return.doc-code,
    first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code,
    first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code:
    find first buf_chk-gds-pay no-lock where buf_chk-gds-pay.line-num = buf_chk-gds.line-num and buf_chk-gds-pay.doc-code = buf_chk-gds.doc-code no-error .
    ii = ii + 1 .
    find first tt-gds-pay where tt-gds-pay.doc-code = tt-return.doc-code and tt-gds-pay.obj-code = tt-return.obj-code 
      and tt-gds-pay.obj-type = tt-return.obj-type and tt-gds-pay.line-num = ii no-error .
    if not available (tt-gds-pay) then 
    do:
      create tt-gds-pay .
      assign
        tt-gds-pay.doc-code = tt-return.doc-code
        tt-gds-pay.obj-code = tt-return.obj-code
        tt-gds-pay.obj-type = tt-return.obj-type
        tt-gds-pay.line-num = ii
        tt-gds-pay.gds-code = buf_goods.gds-code
        tt-gds-pay.gds-name = buf_goods.gds-name .
      if available (buf_chk-gds-pay) then tt-gds-pay.price    = buf_chk-gds-pay.price-base .
      tt-gds-pay.qnty     = buf_chk-gds.doc-qnty .
      if available (buf_chk-gds-pay) then tt-gds-pay.sum_     = buf_chk-gds-pay.tot-r-b . 

      if buf_chk-gds.d-card <> ? then do:
      if length (buf_chk-gds.d-card) = 9 then tt-gds-pay.d-card = "XXXXX" + substring (buf_chk-gds.d-card,5,4).
      else tt-gds-pay.d-card = substring(buf_chk-gds.d-card,1,6) + "XXXXXX" + substring (buf_chk-gds.d-card,13,4).
      end.
      else tt-gds-pay.d-card = "" .  
    end.  
  end.
     
  for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-doc.doc-code:
    jj = jj + 1 .  
    find first tt-gds-pay where tt-gds-pay.doc-code = buf_chk-pay.doc-code and tt-gds-pay.obj-code = buf_chk-pay.obj-code 
      and tt-gds-pay.obj-type = buf_chk-pay.obj-type and tt-gds-pay.line-num = jj no-error .
    if not available (tt-gds-pay) then 
    do:
      create tt-gds-pay .
      assign
        tt-gds-pay.doc-code = buf_chk-pay.doc-code
        tt-gds-pay.line-num = jj
        tt-gds-pay.obj-code = buf_chk-pay.obj-code
        tt-gds-pay.obj-type = buf_chk-pay.obj-type
        .
    end.  
    assign
      tt-gds-pay.pay-type  = string(buf_chk-pay.pay-code)
      tt-gds-pay.pay_qnty  = buf_chk-pay.tot-rubl
      tt-gds-pay.sum_total = buf_chk-doc.tot-doc
      .
    if buf_chk-pay.pay-card <> ? and buf_chk-pay.pay-card <> "" and buf_chk-pay.pay-card <> "0" then do:  
    if length (buf_chk-pay.pay-card) = 9 then tt-gds-pay.p-card = "XXXXX" + substring (buf_chk-pay.pay-card,5,4).
    else tt-gds-pay.p-card = substring(buf_chk-pay.pay-card,1,6) + "XXXXXX" + substring (buf_chk-pay.pay-card,13,4).
    end.  
    run ConvertStr-pay-type(INPUT buf_chk-pay.pay-code,OUTPUT tt-gds-pay.pay-type) .
    for first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "CPAgreement"
      and buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code and buf_chk-pay-attr.line-num = buf_chk-pay.line-num:
      tt-gds-pay.print = 1 .
    end.  
    for first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "sbpstat"
      and buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code and buf_chk-pay-attr.line-num = buf_chk-pay.line-num:
      tt-gds-pay.sbpstat = buf_chk-pay-attr.attr-value .
    end.  
    for first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "sbprrn"
      and buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code and buf_chk-pay-attr.line-num = buf_chk-pay.line-num:
      tt-gds-pay.sbprrn = buf_chk-pay-attr.attr-value .
    end.       
            if p-oplat <> "" and LOOKUP(string(buf_chk-pay.pay-code), p-oplat) = 0 then do:
              if available (tt-gds-pay) then delete tt-gds-pay .
              if available (tt-return) then  delete tt-return .
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

    if p-itog then do:
  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '</tr>' skip
    .
                        
 
  put stream OutStr-html unformatted
    '<TR><TD colspan="14"></TD></TR>' skip
    '<TR>' skip
    '<TD colspan="14" style="font-weight: bold;">Отчет для контроля возвратных операций</TD>' skip
    '</TR>'skip
                                
    '<TR>' skip
    '<TD colspan="14">' + v-period + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="14">' + v-obj-name + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="14">Выбор объекта:</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="14">' + "АЗК №" + v-list-obj + " маг" + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="14">' + v-print-date + '</TD>' skip
    '</TR>'skip

    '</thead>' skip
    '<tbody>' skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Дата и время чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Название АЗК/АЗС</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Номер чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Тип чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Номер кассы</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">ФИО кассира</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Номер дисконтной карты</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Вид оплаты</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Номер платежной карты</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Сумма возврата по типу оплаты</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Общая сумма возврата</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Печать без повторного обращения к ПЦ</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Неопределенный статус возврата через СБП</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">RRN СБП</TD>' skip
    '</TR>'skip       
    .        
    end.
    else do:    
  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '</tr>' skip
    .
                        
 
  put stream OutStr-html unformatted
    '<TR><TD colspan="19"></TD></TR>' skip
    '<TR>' skip
    '<TD colspan="19" style="font-weight: bold;">Отчет для контроля возвратных операций</TD>' skip
    '</TR>'skip
                                
    '<TR>' skip
    '<TD colspan="19">' + v-period + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="19">' + v-obj-name + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="17">Выбор объекта:</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="19">' + "АЗК №" + v-list-obj + " маг" + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="19">' + v-print-date + '</TD>' skip
    '</TR>'skip

    '</thead>' skip
    '<tbody>' skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Дата и время чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Название АЗК/АЗС</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Номер чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Тип чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Номер кассы</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">ФИО кассира</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Код товара</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Название товара</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Цена в чеке</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Количество в чеке</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Стоимость в чеке</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Номер дисконтной карты</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Вид оплаты</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Номер платежной карты</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Сумма возврата по типу оплаты</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Общая сумма возврата</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Печать без повторного обращения к ПЦ</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Неопределенный статус возврата через СБП</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">RRN СБП</TD>' skip
    '</TR>'skip       
    .
    end.
    
  for each tt-return:
    v-pay-line = no .
    v-gds-line = no .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-return.date_,"99/99/9999") + " " + string(tt-return.time_,"HH:MM:SS") + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-return.obj-name) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-return.chk-num) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-return.chk-type) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-return.cash-num) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-return.fio) + '</TD>' skip
      .
 if not p-itog then do:    
    for each tt-gds-pay where tt-gds-pay.doc-code = tt-return.doc-code and tt-gds-pay.obj-code = tt-return.obj-code and tt-gds-pay.obj-type = tt-return.obj-type:
      if v-gds-line then 
      do:
        put stream OutStr-html unformatted
          '<TR>' skip
          '<TD text_wrap="true" style="text-align: center;"></TD>' skip
          '<TD text_wrap="true" style="text-align: center;"></TD>' skip
          '<TD text_wrap="true" style="text-align: center;"></TD>' skip
          '<TD text_wrap="true" style="text-align: center;"></TD>' skip
          '<TD text_wrap="true" style="text-align: center;"></TD>' skip
          '<TD text_wrap="true" style="text-align: center;"></TD>' skip
          .
      end.
      put stream OutStr-html unformatted
        '<TD text_wrap="true" style="text-align: center;">' + if tt-gds-pay.gds-code <> 0 then string(tt-gds-pay.gds-code) + '</TD>' else " "  + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-gds-pay.gds-name) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-gds-pay.price <> 0 then fnc-convert-dot-to-colon(tt-gds-pay.price,"->>>>>>>>>>>9.99",2) + '</TD>' else " " + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-gds-pay.qnty <> 0 then fnc-convert-dot-to-colon(tt-gds-pay.qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else " " + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-gds-pay.sum_ <> 0 then fnc-convert-dot-to-colon(tt-gds-pay.sum_,"->>>>>>>>>>>9.99",2) + '</TD>' else " " + '</TD>' skip
        .
      put stream OutStr-html unformatted
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-gds-pay.d-card) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-gds-pay.pay-type) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if tt-gds-pay.p-card <> "0" then string(tt-gds-pay.p-card) + '</TD>' else " " + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-gds-pay.pay_qnty <> 0 then fnc-convert-dot-to-colon(tt-gds-pay.pay_qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else " " + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-gds-pay.sum_total <> 0 then fnc-convert-dot-to-colon(tt-gds-pay.sum_total,"->>>>>>>>>>>9.99",2) + '</TD>' else " " + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if tt-gds-pay.sum_total <> 0 then string(tt-gds-pay.print) + '</TD>' else " " + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-gds-pay.sbpstat) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-gds-pay.sbprrn) + '</TD>' skip
        '</TR>'skip
        .
      v-gds-line = yes .
    end.
end.
else do:
    for first tt-gds-pay where tt-gds-pay.doc-code = tt-return.doc-code and tt-gds-pay.obj-code = tt-return.obj-code and tt-gds-pay.obj-type = tt-return.obj-type and tt-gds-pay.line-num = 1:
          put stream OutStr-html unformatted
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-gds-pay.d-card) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-gds-pay.pay-type) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if tt-gds-pay.p-card <> "0" then string(tt-gds-pay.p-card) + '</TD>' else " " + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-gds-pay.pay_qnty <> 0 then fnc-convert-dot-to-colon(tt-gds-pay.pay_qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else " " + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-gds-pay.sum_total <> 0 then fnc-convert-dot-to-colon(tt-gds-pay.sum_total,"->>>>>>>>>>>9.99",2) + '</TD>' else " " + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if tt-gds-pay.sum_total <> 0 then string(tt-gds-pay.print) + '</TD>' else " " + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-gds-pay.sbpstat) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-gds-pay.sbprrn) + '</TD>' skip
        '</TR>'skip
        .
      end.  
end.            
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

procedure ConvertStr-chk-type: 
  
  define input parameter p-chk-type as character no-undo.
  define output parameter p-name-chk-type as character no-undo.
  define variable v-num-element as integer no-undo.

  /* Код_вида_расходов. Получение номера элемента в списке кодов */
  v-num-element = lookup(p-chk-type, {&receipt-codes}).

  /* Получение наименования код_вида_расходов по полученному элементу из списка наименований */
  p-name-chk-type = entry(v-num-element, {&receipt-codes-full}).
  if p-chk-type <> "" and v-num-element = 0 then
  do:
    message "Ошибка 115." view-as alert-box.
    return.
  end.

end procedure.

procedure ConvertStr-pay-type: 
  
  define input parameter p-pay-code as integer no-undo.
  define output parameter p-name-pay-type as character no-undo.
  
  find first ub.cash-pay no-lock where ub.cash-pay.cdpay-code = p-pay-code and ub.cash-pay.status_ = {&current-status} no-error .
  if available (ub.cash-pay) then p-name-pay-type = ub.cash-pay.obj-name .
end procedure.