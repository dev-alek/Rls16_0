block-level on error undo, throw.
/*

$Revision: 549cf341336a, 1921, rls $
$Author: EShklyar $
$Date: Tue Jun 25 15:59:58 2019 +0300 $
$Workfile: r-change_price.p $
$Archive: rep/r-change_price.p $

Отчет по изменению розничных цен в соответствии с МРЦ

Автор: Комаров Иван Сергеевич
Дата создания: 03/29/10
Author: Ivan Komarov
Creation date: 03/29/10

*/

define variable vss-revision    as character no-undo init "$Revision: 549cf341336a, 1921, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jun 25 15:59:58 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-change_price.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-change_price.p $":U .
define variable vss-description as character no-undo init "Отчет по изменению розничных цен в соответствии с МРЦ".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.

{ cmp/str-glbl.i }
/*{ adm/auto-def.i }*/
{ cmp/r-page1.i  }
{ cmp/library.i  }
{ gbl/prn-lib.i  }

define temp-table tt-price
  field obj-code     as integer
  field pay-desk     as integer
  field cashier-code as character
  field cashier-fio  as character
  field date_        as date
  field time_        as character
  field gds-code     as integer
  field gds-name     as character
  field old-price    as decimal
  field price        as decimal
  field dif-price    as decimal
  field shift-date   as date
  field shift-num    as integer
  field menedger     as character
  field menedger-fio as character
  field chk-doc      as character
  INDEX pi IS PRIMARY UNIQUE
  obj-code
  gds-code
  chk-doc

  .

define variable p-report-id          as character no-undo .
define variable v-file-name-rep-html as character no-undo .
define variable ii                   as integer   no-undo .
define variable v-name               as character no-undo .
define variable v-name-report        as character no-undo .
define variable v-obj-name           as character no-undo .
define stream Out-Stream.
define stream OutStr-html.

define buffer buf_chk-doc      for ub.chk-doc.
define buffer buf_chk-gds      for ub.chk-gds.
define buffer buf_bar-code     for ub.bar-code.
define buffer buf_goods        for ub.goods.
define buffer buf_goods-attr   for ub.goods-attr.
define buffer buf_tt-price     for tt-price .
define buffer buf_person       for ub.person .
define buffer buf_chk-gds-attr for ub.chk-gds-attr .
define buffer buf_inkas        for ub.inkas .

do
  on error undo, return error
  :
 
  if x-TOG-Shift then
    v-name-report = "за период: c " + string(x-date-Start) + " №" + string(x-Shift-Start) + " по " + string(x-Date-End) + " №" + string(x-Shift-End) .
  else
    v-name-report = "за период: c " + string(x-date-Start) + " по " + string(x-Date-End) .  
  for each obj-list no-lock:
    if v-obj-name <> "" then v-obj-name = v-obj-name + ", " + obj-list.obj-type + " " + string(obj-list.obj-code) .
    else v-obj-name = obj-list.obj-type + " " + string(obj-list.obj-code) .
    for each buf_inkas no-lock where buf_inkas.obj-code = obj-list.obj-code
      and buf_inkas.obj-type = obj-list.obj-type
      and ((buf_inkas.fact-date <= x-Date-End
      and buf_inkas.fact-date >= x-Date-Start) or
      buf_inkas.fact-date = x-Date-Alone ):
      if x-TOG-Shift then 
      do:
        if buf_inkas.shift-date = x-Date-Start and buf_inkas.shift-num < x-Shift-Start then next .
        if buf_inkas.shift-date = x-date-End   and buf_inkas.shift-num > x-Shift-End then next .
      end.  
       
      for each buf_chk-doc no-lock                                                         /* Фильтруем чеки по объектам, датам и типам чеков */
        where buf_chk-doc.out-code = buf_inkas.inkas-code:
        if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next .
      
        for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code,
          first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code,
          first buf_goods no-lock where buf_bar-code.gds-code = buf_goods.gds-code,
          first buf_chk-gds-attr no-lock where buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
          and buf_chk-gds-attr.line-num = buf_chk-gds.line-num
          and buf_chk-gds-attr.attr-code = "CSPriceOrig":
        
          find first buf_tt-price where buf_tt-price.obj-code = obj-list.obj-code and buf_tt-price.gds-code = buf_goods.gds-code and buf_tt-price.chk-doc = buf_chk-doc.doc-code no-error .
          if not available (buf_tt-price) then 
          do:
            create buf_tt-price .
            assign
              buf_tt-price.chk-doc    = buf_chk-doc.doc-code
              buf_tt-price.date_      = buf_chk-doc.chk-date
              buf_tt-price.time_      = string(truncate (buf_chk-doc.chk-time / 3600, 0)) + ":" + string((buf_chk-doc.chk-time modulo 3600) / 60,"99")
              buf_tt-price.gds-code   = buf_goods.gds-code
              buf_tt-price.gds-name   = buf_goods.gds-name
              buf_tt-price.pay-desk   = buf_chk-doc.pay-desk
              buf_tt-price.obj-code   = buf_chk-doc.obj-code
              buf_tt-price.shift-date = buf_inkas.shift-date
              buf_tt-price.shift-num  = buf_inkas.shift-num
              buf_tt-price.price      = abs(buf_chk-gds.price-base * buf_chk-gds.doc-qnty)
              buf_tt-price.old-price  = decimal(buf_chk-gds-attr.attr-value)
              buf_tt-price.dif-price  = buf_tt-price.old-price - buf_tt-price.price
              .
          
            for first buf_person no-lock where buf_person.psn-code = buf_chk-doc.cashier-psn-code:
              run rep/get-psn.p(input buf_person.psn-code, output v-name ).
              buf_tt-price.cashier-fio = v-name + '  ' + buf_person.name1 + ' ':U + buf_person.name2.
            end .
            find first ub.shift-staff no-lock where ub.shift-staff.shift-date = buf_inkas.shift-date
              and ub.shift-staff.shift-num = buf_inkas.shift-num
              and ub.shift-staff.obj-code = buf_chk-doc.obj-code
              and ub.shift-staff.obj-type = buf_chk-doc.obj-type 
              and ub.shift-staff.staff-role = yes no-error .
            if available (ub.shift-staff) then 
            do:  
              for first buf_person no-lock where buf_person.psn-code = ub.shift-staff.psn-code:
                run rep/get-psn.p(input buf_person.psn-code, output v-name ).
                buf_tt-price.menedger-fio = v-name + '  ' + buf_person.name1 + ' ':U + buf_person.name2.
              end .      
            end.  
          end.           
        
        end. /*for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code*/
      end. /*for each buf_chk-doc no-lock */
    end. /*for each tt-obj no-lock:*/
  end.
  /*печать*/
  run get-report-num (output p-report-id).
    
  v-file-name-rep-html = session:temp-directory + string(p-report-id) + ".html".   

  run print-report .

  run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-html
    ). 


PROCEDURE print-report :
    
  output stream OutStr-html to value(v-file-name-rep-html) convert target 'UTF-8'.
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
    '<body>' skip
    .
                        
  /*Печать*/
  put stream OutStr-html unformatted
    '<TABLE fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0" name="Отчет">'skip
    .

  put stream OutStr-html unformatted
    '<thead>' skip
    '<tr>' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="12" style="align: center;">Отчет по изменению розничных цен в соответствии с МРЦ</td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="12" style="align: center;">' + v-name-report + '</td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="12" style="align: center;">' + "по объектам: " + v-obj-name + '</td>' skip
    '</tr>' skip
    '</thead>' skip
    '<tbody>' skip
    .
        
  put stream OutStr-html unformatted
    '<tr>' skip
    '<th text_wrap="true" style="align: center;">№ п/п</th>' skip
    '<th text_wrap="true" style="align: center;">№ АЗК</th>' skip
    '<th text_wrap="true" style="align: center;">№ POS</th>' skip
    '<th text_wrap="true" style="align: center;">ФИО кассира</th>' skip
    '<th text_wrap="true" style="align: center;">Дата и время продаж</th>' skip
    '<th text_wrap="true" style="align: center;">Внутренний код товара</th>' skip
    '<th text_wrap="true" style="align: center;">Название товара</th>' skip
    '<th text_wrap="true" style="align: center;">Розничная цена в соответствии с БД</th>' skip
    '<th text_wrap="true" style="align: center;">МРЦ</th>' skip
    '<th text_wrap="true" style="align: center;">Разница между розничной ценой и МРЦ</th>' skip
    '<th text_wrap="true" style="align: center;">Дата и номер смены</th>' skip
    '<th text_wrap="true" style="align: center;">ФИО старшего смены</th>' skip
    '</tr>' skip
    .
  ii = 0 .
  for each buf_tt-price:
    ii = ii + 1 .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td style="align: center;">' + string(ii) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(buf_tt-price.obj-code) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(buf_tt-price.pay-desk) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(buf_tt-price.cashier-fio) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(string(buf_tt-price.date_) + " " + buf_tt-price.time_) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(buf_tt-price.gds-code) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(buf_tt-price.gds-name) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(buf_tt-price.old-price) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(buf_tt-price.price) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(buf_tt-price.dif-price) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(string(buf_tt-price.shift-date) + " №" + string(buf_tt-price.shift-num)) + '</td>' skip
      '<td text_wrap="true" style="align: center;">' + string(buf_tt-price.menedger-fio) + '</td>' skip
      '</tr>' skip
      .
  end.
  put stream OutStr-html unformatted
    '</tbody>' skip  
    '</table>' skip
    .

  put stream OutStr-html unformatted
        
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.                                                                                                             
END PROCEDURE.

   



PROCEDURE get-report-num :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

end.