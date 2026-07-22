block-level on error undo, throw.
/*

$Revision: 45afebdf84b6, 1359, rls $
$Author: EShklyar $
$Date: Tue May 22 14:25:55 2018 +0300 $
$Workfile: r-detcorchk.p $
$Archive: rep/r-detcorchk.p $

Детализированный отчет по чекам коррекции

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

define variable vss-revision    as character no-undo init "$Revision: 45afebdf84b6, 1359, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue May 22 14:25:55 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-detcorchk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-detcorchk.p $":U .
define variable vss-description as character no-undo init "Детализированный отчет по чекам коррекции".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/html-conv.i }
{ gbl/prn-lib.i     }

define buffer buf_obj-list  for obj-list .
define buffer buf_clients   for ub.clients .
define buffer buf_chk-doc   for ub.chk-doc .
define buffer buf_shift-obj for ub.shift-obj .

define stream Out-Stream.
define stream OutStr-html.

function pr-objname returns character 
  (input p-obj-code as integer ) forward.

function pr-cashier returns character 
(input p-cashier-code as integer ) forward.

function pr-rastype returns character 
(input p-rastype-code as integer ) forward.

function pr-cortype returns character 
(input p-cortype-code as character ) forward.

define variable v-file-name-rep-htm as character no-undo .

define variable ii                  as integer   no-undo .


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
    '<tr>' skip
    '<td style="width: 20px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 200px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '</tr>' skip
    .
                        
 
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: center; font-weight:bold;">Отчет по кассовым чекам коррекции за период с ' + string(x-Date-Start,"99.99.99") + ' по ' + string(x-Date-End,"99.99.99") + ' </td>' skip
    '</tr>' skip   
    '</thead>' skip .
  
end.

procedure pr-line:
                      
                    
  put stream OutStr-html unformatted
    '<tbody>' skip
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ДАТА</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ВРЕМЯ</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">СМЕНА</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">КАССА</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">КАССИР</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ТИП КОРРЕКЦИИ</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ОСНОВАНИЕ КОРРЕКЦИИ</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ТИП РАСЧЕТА</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">СУММА, РУБ.</TD>' skip
    '</TR>'skip
    .
                            
  for each buf_obj-list no-lock:
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="10" style="text-align: left; font-weight:bold;">По объекту: ' + string(buf_obj-list.obj-code) + ' ' + pr-objname(buf_obj-list.obj-code) + ' </td>' skip
      '</tr>' skip   
      '</thead>' skip .

    if x-TOG-Shift = yes then 
    do:

      for each buf_chk-doc no-lock 
        where buf_chk-doc.obj-code = buf_obj-list.obj-code 
        and buf_chk-doc.obj-type = buf_obj-list.obj-type
        and buf_chk-doc.shift-date >= x-Date-Start 
        and buf_chk-doc.shift-date <= x-Date-End
        and buf_chk-doc.out-code <> ?
        and (buf_chk-doc.chk-type = integer({&income-corr}) or buf_chk-doc.chk-type = integer({&expense-corr})):
      
        if (buf_chk-doc.shift-date = X-date-Start)
          and (buf_chk-doc.shift-num < x-Shift-Start) then next. 
        if (buf_chk-doc.shift-date = X-date-End)
          and (buf_chk-doc.shift-num > x-Shift-End) then next.    
       

        ii = ii + 1 .
    
        put stream OutStr-html unformatted
          '<TR>' skip
          '<TD text_wrap="true" style="text-align: center;">' + STRING (ii) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_chk-doc.chk-date,"99.99.9999") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_chk-doc.chk-time,"HH:MM:SS") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_chk-doc.shift-num) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + STRING(buf_chk-doc.pay-desk) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + pr-cashier(buf_chk-doc.cashier) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + pr-cortype(buf_chk-doc.doc-num2) + '</TD>' skip
          '<TD text_wrap="true">' + string(buf_chk-doc.doc-num) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + pr-rastype(buf_chk-doc.chk-type) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_chk-doc.netto,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_chk-doc.netto,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '</TR>'skip                       
          .     
      end.
    end.
    else 
    do:
      for each buf_chk-doc no-lock 
        where buf_chk-doc.obj-code = buf_obj-list.obj-code 
        and buf_chk-doc.obj-type = buf_obj-list.obj-type
        and buf_chk-doc.chk-date >= x-Date-Start 
        and buf_chk-doc.chk-date <= x-Date-End
        and buf_chk-doc.out-code <> ?
        and (buf_chk-doc.chk-type = integer({&income-corr}) or buf_chk-doc.chk-type = integer({&expense-corr})):
  
        ii = ii + 1 .
    
        put stream OutStr-html unformatted
          '<TR>' skip
          '<TD text_wrap="true" style="text-align: center;">' + STRING (ii) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_chk-doc.chk-date,"99.99.9999") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_chk-doc.chk-time,"HH:MM:SS") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_chk-doc.shift-num) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + STRING(buf_chk-doc.pay-desk) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + pr-cashier(buf_chk-doc.cashier) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + pr-cortype(buf_chk-doc.doc-num2) + '</TD>' skip
          '<TD text_wrap="true">' + string(buf_chk-doc.doc-num) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + pr-rastype(buf_chk-doc.chk-type) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_chk-doc.netto,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_chk-doc.netto,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '</TR>'skip                       
          .     
      end.
  
    end.  

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

FUNCTION pr-cashier RETURNS character
  ( INPUT p-cashier-code AS integer) :
define variable v-cashier-name as character no-undo .
define buffer buf_staff for ub.staff .
define buffer buf_person for ub.person .
define buffer buf_clients for ub.clients .

for first buf_staff NO-LOCK where buf_staff.staff-code = p-cashier-code and buf_staff.role = {&role-cashier},
first buf_person no-lock where
          buf_person.psn-code = buf_staff.psn-code,
          first buf_clients no-lock where buf_clients.obj-code = buf_person.psn-code and buf_clients.obj-type = {&prs}:
            v-cashier-name = buf_clients.obj-name + " " + (if buf_person.name1 <> "" then SUBSTRING (buf_person.name1,1,1) + "." else "") + (if buf_person.name2 <> "" then SUBSTRING (buf_person.name2,1,1) + "." else "").
          end. 
RETURN v-cashier-name.

END FUNCTION.

FUNCTION pr-rastype RETURNS character
  ( INPUT p-rastype-code AS integer) :
define variable v-rastype-name as character no-undo .

  case p-rastype-code:
    when integer({&income-corr}) then 
      do:
        v-rastype-name = "Приход" .
      end.
    when integer({&expense-corr}) then 
      do:
        v-rastype-name = "Расход" .
      end.    
  end case.  

RETURN v-rastype-name.

END FUNCTION.

FUNCTION pr-cortype RETURNS character
  ( INPUT p-cortype-code AS character) :
define variable v-cortype-name as character no-undo .
define variable v-corrtype     as character no-undo .

v-corrtype = entry(1,p-cortype-code,":") .

  case v-corrtype:
    when "0" then 
      do:
        v-cortype-name = "самостоятельно" .
      end.
    when "1" then 
      do:
        v-cortype-name = "по предписанию" .
      end.    
  end case.  

  RETURN v-cortype-name.

END FUNCTION.

FUNCTION pr-objname RETURNS character
  ( INPUT p-obj-code AS integer) :

  define variable v-obj-name as character no-undo .

  find first ub.clients no-lock where ub.clients.obj-code = p-obj-code and ub.clients.obj-type = {&shop} no-error .
  if AVAILABLE (ub.clients) then v-obj-name = ub.clients.obj-name .
 
  RETURN v-obj-name.

END FUNCTION.