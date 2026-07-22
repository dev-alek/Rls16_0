block-level on error undo, throw.
/*

$Revision: 6f0fa439fecf, 2278, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:24:02 2019 +0300 $
$Workfile: r-corr-check.p $
$Archive: rep/r-corr-check.p $

Отчет по транзакциям коррекции

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

define variable vss-revision    as character no-undo init "$Revision: 6f0fa439fecf, 2278, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:02 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-corr-check.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-corr-check.p $":U .
define variable vss-description as character no-undo init "Отчет по транзакциям коррекции".
{ cmp/vssrevis.i }


define input parameter parparentproc           as handle           no-undo .
define input parameter p-check-type            as character        no-undo .
define input parameter p-osnov-corr            as character        no-undo .
define input parameter p-date-corr             as date             no-undo .
define input parameter p-num-corr              as character        no-undo .
define input parameter p-shift                 as integer          no-undo .

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i      }
{ cmp/r-pril.i   }
{ ref/cp-attr.i }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }        
{ ref/extclass.i }
{ str/is-corr.i }

define temp-table tt-corr-check no-undo
  field obj-code    as integer
  field obj-type    as character
  field obj-name    as character
  field shift-corr  as character
  field shift-num   as character
  field shift-close as character
  field cash-num    as integer
  field chk-num     as character
  field num-z       as integer 
  field time-chk    as character
  field date-corr   as character
  field chk-type    as character
  field chk-sum     as decimal
  field pay-type    as character
  field sum-paytype as decimal
  field osnov-corr  as character
  field date-osnov  as date
  field num-corr    as character 
  INDEX pi obj-code obj-type chk-num pay-type
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
define variable v-osnov-corr        as character no-undo .
define variable v-date-corr         as character no-undo .
define variable v-num-corr          as character no-undo .
define variable v-create-shift-num  as integer   no-undo .
define variable v-create-shift-date as date      no-undo .
define variable v-shift-status      as character no-undo .
define variable ii                  as integer   no-undo .
define buffer buf_chk-doc       for ub.chk-doc .
define buffer bf_chk-doc        for ub.chk-doc .
define buffer buf_chk-doc-attr  for ub.chk-doc-attr .
define buffer buf_shift-obj     for ub.shift-obj .
define buffer buf_chk-pay       for ub.chk-pay . 
define buffer buf_tt-corr-check for tt-corr-check .
define buffer buf_clients       for ub.clients .
define variable v-check-type      as character no-undo .
define variable v-osnov-corr_name as character no-undo .
define variable v-date-corr_name  as character no-undo .
define variable v-num-corr_name   as character no-undo .
define variable v-shift           as character no-undo .
define variable v-change          as character no-undo .
define variable v-create-time     as character no-undo .
define variable v-create-date     as character no-undo .
define stream Out-Stream.
define stream OutStr-html.

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
 
  if p-check-type <> "" then v-check-type = "Тип чека: " + ChkType(integer(p-check-type)) . 
  else v-check-type = "По всем типам чеков" .
  if p-osnov-corr <> "0" then v-osnov-corr_name = "Документ основания: " + OsnovCorr(integer(p-osnov-corr)) .
  if p-date-corr <> ? then v-date-corr_name = "Дата документа основания: " + string(p-date-corr) .
  if p-num-corr <> "" then v-num-corr_name = "Номер документа основания: " + p-num-corr .

  if p-check-type = "" then p-check-type = {&receipt-codes-combo} .
  
  case p-shift:
    when 0 then 
      v-shift = "По всем сменам" .
    when 1 then 
      v-shift = "По закрытым сменам" .
    when 2 then 
      v-shift = "По открытым сменам" .
  end case.    

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
        and buf_chk-doc.out-code <> ?:
        if p-check-type <> "" then 
        do:
          if lookup(string(buf_chk-doc.chk-type), p-check-type) = 0 then next .
        end.
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
        :
        if p-check-type <> "" then 
        do:
          if lookup(string(buf_chk-doc.chk-type), p-check-type) = 0 then next .
        end.
        run report .
      end.  
    end.  
    
  

/*Общие данные*/
procedure report:
  if p-shift > 0 then 
  do:
    if p-shift = 1 then 
    do:
      find first buf_shift-obj no-lock where buf_shift-obj.obj-code = buf_chk-doc.obj-code
        and buf_shift-obj.obj-type = buf_chk-doc.obj-type 
        and buf_shift-obj.shift-date = buf_chk-doc.shift-date
        and buf_shift-obj.shift-num = buf_chk-doc.shift-num
        and buf_shift-obj.status_ = {&sht-closed} no-error .
    end.  
    else 
    do:
      find first buf_shift-obj no-lock where buf_shift-obj.obj-code = buf_chk-doc.obj-code
        and buf_shift-obj.obj-type = buf_chk-doc.obj-type 
        and buf_shift-obj.shift-date = buf_chk-doc.shift-date
        and buf_shift-obj.shift-num = buf_chk-doc.shift-num
        and buf_shift-obj.status_ = {&sht-current} no-error .
    end.
    if not available (buf_shift-obj) then next .  
  end.  

  find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
    and buf_chk-doc-attr.attr-code  = "create-type" and buf_chk-doc-attr.attr-value = "manual" no-error .
  if not available (buf_chk-doc-attr) then 
  do:
    if buf_chk-doc.chk-type <> integer({&income-corr}) and buf_chk-doc.chk-type <> integer({&expense-corr}) then next .
    if num-entries(buf_chk-doc.doc-num, ",") > 2 then v-osnov-corr = entry(3,buf_chk-doc.doc-num,",") .     
    if p-osnov-corr <> "0" and p-osnov-corr <> "" then 
      if v-osnov-corr <> p-osnov-corr then next . 

    if num-entries(buf_chk-doc.doc-num, ",") > 0 then v-date-corr = entry(1,buf_chk-doc.doc-num,",") .
    if p-date-corr <> ? then 
      if p-date-corr <> date(v-date-corr) then next .  
 
    if num-entries(buf_chk-doc.doc-num, ",") > 1 then v-num-corr = entry(2,buf_chk-doc.doc-num,",") .  
    if p-num-corr <> "" then 
      if p-num-corr <> v-num-corr then next .
  end.
  else 
  do:
    if p-osnov-corr <> "0" and p-osnov-corr <> "" then 
    do:
      find first buf_chk-doc-attr no-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
        and buf_chk-doc-attr.attr-code = "corr-osnov" and buf_chk-doc-attr.attr-value = string(p-osnov-corr) no-error .
      if not available (buf_chk-doc-attr) then next .
      else v-osnov-corr = OsnovCorr(integer(p-osnov-corr)) .
    end.
    else 
    do:
      find first buf_chk-doc-attr no-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
        and buf_chk-doc-attr.attr-code = "corr-osnov" no-error .
      if available (buf_chk-doc-attr) then v-osnov-corr = OsnovCorr(integer(buf_chk-doc-attr.attr-value)) .
    end.    
    if p-date-corr <> ? then 
    do:
      find first buf_chk-doc-attr no-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
        and buf_chk-doc-attr.attr-code = "corr-date" and buf_chk-doc-attr.attr-value = string(p-date-corr) no-error .
      if not available (buf_chk-doc-attr) then next .
      else v-date-corr = string(p-date-corr) .
    end.  
    else 
    do:
      find first buf_chk-doc-attr no-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
        and buf_chk-doc-attr.attr-code = "corr-date" no-error .
      if available (buf_chk-doc-attr) then v-date-corr = buf_chk-doc-attr.attr-value .
    end.    
    if p-num-corr <> "" then 
    do:
      find first buf_chk-doc-attr no-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
        and buf_chk-doc-attr.attr-code = "corr-num" and buf_chk-doc-attr.attr-value = p-num-corr no-error .
      if not available (buf_chk-doc-attr) then next .
      else v-num-corr = p-num-corr .
    end.      
    else 
    do:
      find first buf_chk-doc-attr no-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
        and buf_chk-doc-attr.attr-code = "corr-num" no-error .
      if available (buf_chk-doc-attr) then v-num-corr = buf_chk-doc-attr.attr-value .

    end.
    
  end.  

  v-create-shift-date = ? .
  v-create-shift-num = 0 .
  find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
    and buf_chk-doc-attr.attr-code  = "create-shift-num" no-error .           
  if available (buf_chk-doc-attr) then v-create-shift-num = integer (buf_chk-doc-attr.attr-value) .    
  find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
    and buf_chk-doc-attr.attr-code  = "create-shift-date" no-error .           
  if available (buf_chk-doc-attr) then v-create-shift-date = date (buf_chk-doc-attr.attr-value) .    
  find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
    and buf_chk-doc-attr.attr-code  = "create-date" no-error .           
  if available (buf_chk-doc-attr) then v-create-date = buf_chk-doc-attr.attr-value .    
  find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
    and buf_chk-doc-attr.attr-code  = "create-time" no-error .           
  if available (buf_chk-doc-attr) then v-create-time = buf_chk-doc-attr.attr-value .    
    
  if (v-create-shift-date = buf_chk-doc.shift-date and v-create-shift-num = buf_chk-doc.shift-num) or v-create-shift-date = ? or v-create-shift-num = 0 then v-shift-status =  "-" .
  else v-shift-status = "да" .    

  
  create tt-corr-check .
  assign
    tt-corr-check.obj-code    = buf_chk-doc.obj-code
    tt-corr-check.shift-corr  = if v-create-shift-date <> ? then string(v-create-shift-date) + " " + string(v-create-shift-num) else string(v-create-shift-num) 
    tt-corr-check.shift-num   = string(buf_chk-doc.shift-date) + " " + string(buf_chk-doc.shift-num)
    tt-corr-check.shift-close = v-shift-status
    tt-corr-check.cash-num    = buf_chk-doc.pay-desk
    tt-corr-check.chk-num     = string(buf_chk-doc.doc-code)
    tt-corr-check.num-z       = buf_chk-doc.z-number
    tt-corr-check.time-chk    = string(buf_chk-doc.chk-date,"99.99.9999") + " " + string(buf_chk-doc.chk-time,"HH:MM:SS")
    tt-corr-check.date-corr   = string (v-create-date) + " " + string (v-create-time)
    tt-corr-check.chk-sum     = buf_chk-doc.tot-doc
    tt-corr-check.osnov-corr  = v-osnov-corr
    tt-corr-check.date-osnov  = date(v-date-corr)
    tt-corr-check.num-corr    = v-num-corr
    tt-corr-check.sum-paytype = 0 .
    tt-corr-check.chk-type    = ChkType(buf_chk-doc.chk-type)
    .
    run clients-write(INPUT buf_chk-doc.obj-code, INPUT buf_chk-doc.obj-type, OUTPUT tt-corr-check.obj-name) no-error .   
  for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-doc.doc-code:
    assign  
      tt-corr-check.sum-paytype = buf_chk-pay.tot-sum
      .
    tt-corr-check.pay-type    = PayType(buf_chk-pay.pay-code).
  end.          

end procedure .
    /*печать*/

    run get-report-num (output p-report-id).
    
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
    ii = 0 .                  
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
      '<td style="width: 40px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '</tr>' skip
      .
                        
 
    put stream OutStr-html unformatted
      '<TR><TD colspan="17"></TD></TR>' skip
      '<TR>' skip
      '<TD colspan="17" style="font-weight: bold;">Отчет по Транзакциям коррекции</TD>' skip
      '</TR>'skip
                                
      '<TR>' skip
      '<TD colspan="17">' + v-period + '</TD>' skip
      '</TR>'skip

      '<TR>' skip
      '<TD colspan="17">' + v-obj-name + '</TD>' skip
      '</TR>'skip

      '<TR>' skip
      '<TD colspan="17">Выбор объекта:</TD>' skip
      '</TR>'skip

      '<TR>' skip
      '<TD colspan="17">' + "АЗК №" + v-list-obj + " маг" + '</TD>' skip
      '</TR>'skip

      '<TR>' skip
      '<TD colspan="17">' + v-print-date + '</TD>' skip
      '</TR>'skip
      .
    if v-check-type <> "" then 
    do:
      put stream OutStr-html unformatted
        '<TR><TD colspan="17">' + v-check-type + '</TD></TR>' skip
        .    
    end.

    if v-osnov-corr_name <> "" then 
    do:
      put stream OutStr-html unformatted
        '<TR><TD colspan="17">' + v-osnov-corr_name + '</TD></TR>' skip
        .    
    end.   
   
    if v-date-corr_name <> "" then 
    do:
      put stream OutStr-html unformatted
        '<TR><TD colspan="17">' + v-date-corr_name + '</TD></TR>' skip
        .    
    end.      

    if v-num-corr_name <> "" then 
    do:
      put stream OutStr-html unformatted
        '<TR><TD colspan="17">' + v-num-corr_name + '</TD></TR>' skip
        .    
    end.   

    if v-shift <> "" then 
    do:
      put stream OutStr-html unformatted
        '<TR><TD colspan="17">' + v-shift + '</TD></TR>' skip
        .    
    end.   

    put stream OutStr-html unformatted
      '</thead>' skip
      '<tbody>' skip
      .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">№</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">АЗС</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Смена корректи- руемого расчета</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Смена формиро- вания транзакции</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Корр. в закрытой смене</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Касса</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Номер чека</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Номер Z-отчета</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Дата и время формиро- вания транзакции</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Дата корректи- руемого расчета</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Тип чека</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Сумма чека, руб.</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Тип оплаты</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Сумма по типу оплаты</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Документ основания для коррекции</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Дата документа основания</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Номер документа основания</TD>' skip
      '</TR>'skip       
                    
      .
    
    for each buf_tt-corr-check by obj-code:
      ii = ii + 1 .
      put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(ii) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-corr-check.obj-name) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-corr-check.shift-num) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-corr-check.shift-corr) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-corr-check.shift-close) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-corr-check.cash-num) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-corr-check.chk-num) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-corr-check.num-z) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-corr-check.date-corr) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-corr-check.time-chk) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-corr-check.chk-type) + '</TD>' skip
        '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-corr-check.chk-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-corr-check.chk-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if buf_tt-corr-check.pay-type = "" then "Служебн." + '</TD>' else buf_tt-corr-check.pay-type + '</TD>' skip
        '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-corr-check.sum-paytype,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-corr-check.sum-paytype,"->>>>>>>>>>>9.99",2) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if buf_tt-corr-check.osnov-corr <> "" then string(buf_tt-corr-check.osnov-corr) + '</TD>' else ""  + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if buf_tt-corr-check.date-osnov <> ? then string(buf_tt-corr-check.date-osnov) + '</TD>' else "" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if buf_tt-corr-check.num-corr <> "" then string(buf_tt-corr-check.num-corr) + '</TD>' else "" + '</TD>' skip
        '</TR>'skip     
        .
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
