block-level on error undo, throw.
/*

$Revision: 7fffee6e7c2f, 2684, rls $
$Author: EShklyar $
$Date: Пт дек 18 18:16:04 2020 +0300 $
$Workfile: r-promo-chk.p $
$Archive: rep/r-promo-chk.p $

Оперативный отчет по реализации промо-акций.

Автор: Шкляр Елена
Дата создания: 04/29/10
Author: Elena Shklyar
Creation date: 04/29/10

*/
define input parameter parparentproc            as widget-handle           no-undo .
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-call-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo . /*для ошибок*/
define input parameter p-rdbh                   as handle                  no-undo . /*destination*/
define input parameter p-report-id              as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer                 no-undo .
define input parameter p-ruleset-id             as integer                 no-undo .
define input parameter p-plain-txt              as logical                 no-undo .
define input parameter p-xls                    as logical                 no-undo .
define input parameter p-dir-name               as character               no-undo .

define variable vss-revision    as character no-undo init "$Revision: 7fffee6e7c2f, 2684, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пт дек 18 18:16:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-promo-chk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-promo-chk.p $":U .
define variable vss-description as character no-undo init "Оперативный отчет по реализации промо-акций.".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/html-conv.i }
{ gbl/prn-lib.i     }

define buffer buf_obj-list    for obj-list .
define buffer buf_clients     for ub.clients .
define buffer buf_chk-doc     for ub.chk-doc .
define buffer buf_shift-obj   for ub.shift-obj .
define buffer buf_chk-discnt  for ub.chk-discnt .
define buffer bf_chk-discnt   for ub.chk-discnt .
define buffer buf_chk-gds     for ub.chk-gds .
define buffer buf_PromoAction for ub.PromoAction .

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
  
define variable v-obj-list-code       as integer.
define variable v-obj-list-type       as char.
define variable v-cntxt-obj-name      as character no-undo .
define variable v-cntxt-host-name-obj as character no-undo .

define stream Out-Stream.
define stream OutStr-html.

function pr-objname returns character 
  (input p-obj-code as integer ) forward.

define variable v-file-name-rep-htm as character no-undo .

define variable ii                  as integer   no-undo .
define TEMP-TABLE tt-promo 
  field obj-code     as integer
  field obj-type     as character
  field shift-date   as date
  field shift-num    as integer
  field promo-id     as character
  field promo-name   as character
  field object-qnty  as decimal 
  field goods-qnty   as decimal
  field discount-sum as decimal
  field itog-sum     as decimal
  field change-BL    as character
  index pi
  is unique
  obj-code
  promo-id
  obj-type
  shift-date
  shift-num
  
  .  
define TEMP-TABLE tt-shift-obj like ub.shift-obj .

define variable v-sum-with    as decimal no-undo .
define variable v-sum-without as decimal no-undo .

for each buf_obj-list no-lock:
  if x-TOG-Shift = yes then 
  do:
    for each buf_chk-discnt no-lock where buf_chk-discnt.record-type = 5
      and buf_chk-discnt.obj-code = buf_obj-list.obj-code 
      and buf_chk-discnt.obj-type = buf_obj-list.obj-type
      and buf_chk-discnt.out-code <> ?,
      first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_chk-discnt.doc-code
      and buf_chk-doc.shift-date >= x-Date-Start 
      and buf_chk-doc.shift-date <= x-Date-End:   
      /*Кол-во срабатываний*/    
      if (buf_chk-doc.shift-date = X-date-Start)
        and (buf_chk-doc.shift-num < x-Shift-Start) then next. 
      if (buf_chk-doc.shift-date = X-date-End)
        and (buf_chk-doc.shift-num > x-Shift-End) then next.

      find first tt-promo where tt-promo.obj-code = buf_chk-discnt.obj-code and tt-promo.obj-type = buf_chk-discnt.obj-type
        and tt-promo.shift-date = buf_chk-doc.shift-date and tt-promo.shift-num = buf_chk-doc.shift-num and tt-promo.promo-id = buf_chk-discnt.promo-id no-error .
      if not available (tt-promo) then 
      do:
        find first buf_PromoAction no-lock where buf_PromoAction.id = integer(buf_chk-discnt.promo-id) no-error .
        
        create tt-promo .
        assign
          tt-promo.obj-code    = buf_chk-discnt.obj-code
          tt-promo.obj-type    = buf_chk-discnt.obj-type
          tt-promo.object-qnty = buf_chk-discnt.object-sum
          tt-promo.promo-id    = string(buf_chk-discnt.promo-id)
          tt-promo.shift-date  = buf_chk-doc.shift-date
          tt-promo.shift-num   = buf_chk-doc.shift-num
          tt-promo.promo-name  = if available (buf_PromoAction) then buf_PromoAction.nameAction else "".
        .
        find first ub.promoAttr where
          ub.promoAttr.attr-code = "charge-BL" and
          ub.promoAttr.tablename = "PromoPay" and
          buf_PromoAction.id = int64(entry(1,ub.PromoAttr.p-key,{&delim-key})) and 
          buf_PromoAction.db-num = integer(entry(2,ub.PromoAttr.p-key,{&delim-key})) 
          no-error.
        if available (ub.PromoAttr) then do:
          if logical(ub.PromoAttr.attr-value) = true then tt-promo.change-BL = "да" .
          else tt-promo.change-BL = "нет" .
        end.
        else tt-promo.change-BL = "нет" .
      end.    
      else tt-promo.object-qnty = tt-promo.object-qnty + buf_chk-discnt.object-sum .
                                 
      for each bf_chk-discnt no-lock where bf_chk-discnt.record-type = 1 and bf_chk-discnt.doc-code = buf_chk-discnt.doc-code and bf_chk-discnt.promo-id = buf_chk-discnt.promo-id:   
        /*По товарам*/    
                
        for each buf_chk-gds no-lock where buf_chk-gds.doc-code = bf_chk-discnt.doc-code and buf_chk-gds.line-num = bf_chk-discnt.object-line-num:
        
          assign
            tt-promo.discount-sum = tt-promo.discount-sum + bf_chk-discnt.discnt-value-abs
            tt-promo.goods-qnty   = tt-promo.goods-qnty + buf_chk-gds.doc-qnty
            tt-promo.itog-sum     = tt-promo.itog-sum + buf_chk-gds.src-sum
            .

        end.                              
      end.  

    end.   
  end.

  else 
  do:
    /*без смены*/
    for each buf_chk-discnt no-lock where buf_chk-discnt.record-type = 5
      and buf_chk-discnt.obj-code = buf_obj-list.obj-code 
      and buf_chk-discnt.obj-type = buf_obj-list.obj-type
      and buf_chk-discnt.out-code <> ?
      and buf_chk-discnt.chk-date >= x-Date-Start 
      and buf_chk-discnt.chk-date <= x-Date-End,   
      first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_chk-discnt.doc-code: 
      /*Кол-во срабатываний*/    
      find first tt-promo where tt-promo.obj-code = buf_chk-discnt.obj-code and tt-promo.obj-type = buf_chk-discnt.obj-type
        and tt-promo.shift-date = buf_chk-doc.shift-date and tt-promo.shift-num = buf_chk-doc.shift-num and tt-promo.promo-id = buf_chk-discnt.promo-id no-error .
      if not available (tt-promo) then 
      do:
        find first buf_PromoAction no-lock where buf_PromoAction.id = integer(buf_chk-discnt.promo-id) no-error .
        create tt-promo .
        assign
            tt-promo.obj-code    = buf_chk-discnt.obj-code
            tt-promo.obj-type    = buf_chk-discnt.obj-type
            tt-promo.shift-date = buf_chk-doc.shift-date
            tt-promo.shift-num  = buf_chk-doc.shift-num
            tt-promo.object-qnty = buf_chk-discnt.object-sum
            tt-promo.promo-id    = string(buf_chk-discnt.promo-id)
            tt-promo.promo-name  = if available (buf_PromoAction) then buf_PromoAction.nameAction else "".
        .
      end.    
      else tt-promo.object-qnty = tt-promo.object-qnty + buf_chk-discnt.object-sum .
                                 
      for each bf_chk-discnt no-lock where bf_chk-discnt.record-type = 1 and bf_chk-discnt.doc-code = buf_chk-discnt.doc-code and bf_chk-discnt.promo-id = buf_chk-discnt.promo-id:   
        /*По товарам*/    
                
        for each buf_chk-gds no-lock where buf_chk-gds.doc-code = bf_chk-discnt.doc-code and buf_chk-gds.line-num = bf_chk-discnt.object-line-num:
        
          assign
            tt-promo.discount-sum = tt-promo.discount-sum + bf_chk-discnt.discnt-value-abs
            tt-promo.goods-qnty   = tt-promo.goods-qnty + buf_chk-gds.doc-qnty
            tt-promo.itog-sum     = tt-promo.itog-sum + buf_chk-gds.src-sum
            .

        end.                              
      end.  
    end.
  end.   
end.  


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

run pr-header .
run pr-line .
run pr-foot .

procedure pr-header:
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 200px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '</tr>' skip
    .
                        
 
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="9" style="text-align: center;">Отчет по реализации промо-акций за период с ' + string(x-Date-Start,"99.99.99") + ' по ' + string(x-Date-End,"99.99.99") + ' </td>' skip
    '</tr>' skip   
    '</thead>' skip .
  
end.

procedure pr-line:
                      
                    
  put stream OutStr-html unformatted
    '<tbody>' skip
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата смены</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ смены</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ промо-акции</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование промо-акции</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Количество срабатываний</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Количество акционных товаров</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Сумма скидки</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Сумма без скидки</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Запрет начисления БЛ</TD>' skip
    '</TR>'skip
    .
                            
  for each tt-promo by tt-promo.shift-date:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">' + STRING (tt-promo.shift-date,"99.99.99") + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-promo.shift-num) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-promo.promo-id) + '</TD>' skip
      '<TD text_wrap="true">' + string(tt-promo.promo-name) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(if tt-promo.object-qnty <> ? then tt-promo.object-qnty else 0) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + STRING (tt-promo.goods-qnty) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-promo.discount-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-promo.discount-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-promo.itog-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-promo.itog-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + tt-promo.change-BL + '</TD>' skip
      '</TR>'skip                       
      .     
  end.

  put stream OutStr-html unformatted
    '</tbody>' skip .
end.  
  
procedure pr-foot:        
  put stream OutStr-html unformatted
  
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
end.  
                            
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

        
