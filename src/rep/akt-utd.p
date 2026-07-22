/*

$Revision: bea89a1a8b39, 2756, rls $
$Author: EShklyar $
$Date: Сб фев 20 15:59:21 2021 +0300 $
$Workfile: akt-utd.p $
$Archive: rep/akt-utd.p $

Акт-приема передачи товара

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
block-level on error undo, throw.

define variable vss-revision    as character no-undo init "$Revision: bea89a1a8b39, 2756, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: akt-utd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/akt-utd.p $":U .
define variable vss-description as character no-undo init "Акт-приема передачи товара".
{ cmp/vssrevis.i }

define input parameter parparentproc    as widget-handle  no-undo.
define input parameter p-db-num       as integer      no-undo .
define input parameter p-doc-id       as integer      no-undo .

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ str/lib-trn.i class }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ str/edo.i }

&global-define month-list-for-date 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U
/* Для вызова функции конвертации даты к виду: "01 Января 2014г" */
&scop f-l MonthNameRusCase

{ gbl/std-func.i {&f-l} }
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-vendor-name       as character no-undo .
define variable v-vendor-inn        as character no-undo .
define variable v-org-name          as character no-undo .
define variable v-org-inn           as character no-undo . 
define variable v-contr-code        as character no-undo .
define variable v-contr-date        as character no-undo .
define variable v-date              as character no-undo .
define variable v-utd-date          as character no-undo .
define variable v-gds-name          as character no-undo .
define variable v-itog-level        as integer   no-undo .
define variable v-itog-unit         as integer   no-undo . 
define variable v-obj-info          as character no-undo . 
define variable v-gtin              as character no-undo .
define variable ser-level           as character no-undo .

def    var      Marking             as class     mark no-undo .
Marking = ObjSrv:Env:Marking:Sts:Mark .
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer)  FORWARD.
  
define buffer buf_utd               for ub.utd .
define buffer buf_utd-lines         for ub.utd-lines .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer buf_clients           for ub.clients .
define buffer buf_firm              for ub.firm .
define buffer buf_contract          for ub.contract .
define buffer buf_marking           for ub.marking .

define temp-table tt-utd no-undo
  field doc-id     as integer
  field db-num     as integer
  field gds-name   as character 
  field gds-code   as integer
  field gtin       as character 
  field qnty-unit  as integer 
  field qnty-level as integer
  field ser-level  as character 
  field linenum    as integer
  index pi doc-id db-num gds-code linenum
  .

do
  on error undo, return error return-value
  :
  /*Сбор данных*/
  
  find first buf_utd no-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-error .
  if not available (buf_utd) then 
  do:
    message "УПД не найден"
      view-as alert-box.
    return .
  end.  
 
  /*Продавец*/
  find first buf_clients no-lock where buf_clients.obj-code = buf_utd.cli-code and 
    buf_clients.obj-type = buf_utd.cli-type no-error .
   if available (buf_clients) then v-vendor-name = buf_clients.obj-name .
  find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error .
  if available (buf_firm) then 
    v-vendor-inn = "ИНН: " + buf_firm.inn .                                      
 
  /*Покупатель*/
  find first buf_clients no-lock where buf_clients.obj-code = buf_utd.obj-code and 
    buf_clients.obj-type = buf_utd.obj-type no-error .
  if available (buf_clients) then   
  v-obj-info = buf_clients.obj-name .
  find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error .
  if available (buf_firm) then 
    v-obj-info = v-obj-info + " ИНН: " + buf_firm.inn .    
end.   
/*Договор*/
find first buf_contract no-lock where buf_contract.contract-code = buf_utd.contract-code no-error .
if available (buf_contract) then 
do:
  v-contr-code = buf_contract.contract-prn-code .
  run get-DD-Month-YYYY(buf_contract.contract-date, output v-contr-date) .
    
end.  
run get-DD-Month-YYYY(date(today), output v-date) .
run get-DD-Month-YYYY(buf_utd.DocumentDate, output v-utd-date) .

if buf_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB then 
do:     
  for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd.db-num and buf_utd-marking-lines.doc-id = buf_utd.doc-id and 
    buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB:
    find first tt-utd where tt-utd.doc-id = buf_utd-marking-lines.doc-id and tt-utd.db-num = buf_utd-marking-lines.db-num
      and tt-utd.linenum = buf_utd-marking-lines.LineNum and tt-utd.gds-code = buf_utd-marking-lines.gds-code no-error .
    if not available (tt-utd) then 
    do:
      create tt-utd .
      assign
        tt-utd.gds-name = GdsName(buf_utd-marking-lines.gds-code) 
        tt-utd.doc-id   = buf_utd-marking-lines.doc-id
        tt-utd.db-num   = buf_utd-marking-lines.db-num
        tt-utd.linenum  = buf_utd-marking-lines.LineNum
        tt-utd.gds-code = buf_utd-marking-lines.gds-code
        .
    end.  
    if tt-utd.gtin <> "" then 
    do:
      v-gtin = getGtinByDM(buf_utd-marking-lines.mark) .
      if lookup (tt-utd.gtin, v-gtin) = 0 then tt-utd.gtin = tt-utd.gtin + ", " + v-gtin .
    end.
    else tt-utd.gtin = getGtinByDM(buf_utd-marking-lines.mark) .  
    tt-utd.gtin = getGtinByDM(buf_utd-marking-lines.mark) .
    if buf_utd-marking-lines.doc-level = 1 then 
    do:
      assign
        tt-utd.qnty-level = tt-utd.qnty-level + 1 
        .

      if tt-utd.ser-level <> "" then tt-utd.ser-level = tt-utd.ser-level + " " + GetTegCod(buf_utd-marking-lines.mark,"21") .
      else tt-utd.ser-level = GetTegCod(buf_utd-marking-lines.mark,"21") .  

    end.  
    else tt-utd.qnty-unit = tt-utd.qnty-unit + 1 .            
  end.  
end.      

if buf_utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
do:     
  for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd.db-num and buf_utd-marking-lines.doc-id = buf_utd.doc-id:
    find first tt-utd where tt-utd.doc-id = buf_utd-marking-lines.doc-id and tt-utd.db-num = buf_utd-marking-lines.db-num
      and tt-utd.linenum = buf_utd-marking-lines.LineNum and tt-utd.gds-code = buf_utd-marking-lines.gds-code no-error .
    if not available (tt-utd) then 
    do:
      create tt-utd .
      assign
        tt-utd.gds-name = GdsName(buf_utd-marking-lines.gds-code) 
        tt-utd.doc-id   = buf_utd-marking-lines.doc-id
        tt-utd.db-num   = buf_utd-marking-lines.db-num
        tt-utd.linenum  = buf_utd-marking-lines.LineNum
        tt-utd.gds-code = buf_utd-marking-lines.gds-code
        .
      tt-utd.gtin = getGtinByDM(buf_utd-marking-lines.mark) .
    end.  

    if buf_utd-marking-lines.doc-level = 1 then 
    do:
      find first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark no-error .
      assign
        tt-utd.qnty-level = tt-utd.qnty-level + 1 
        .
      tt-utd.qnty-unit = tt-utd.qnty-unit + buf_marking.box-qnty . 

      if tt-utd.ser-level <> "" then tt-utd.ser-level = tt-utd.ser-level + " " + GetTegCod(buf_utd-marking-lines.mark,"21") .
      else tt-utd.ser-level = GetTegCod(buf_utd-marking-lines.mark,"21") .  
      ser-level = "".

    end.  
  /*      else tt-utd.qnty-unit = tt-utd.qnty-unit + 1 .*/
  end.  
end.       
    
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
  '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
  '<thead>' skip
  .
put stream OutStr-html unformatted
  '<tr>' skip
  '<td style="width: 10px;"></td>' skip
    
  '<td style="width: 30px;"></td>' skip
  '<td style="width: 5px;"></td>' skip
  '<td style="width: 20px;"></td>' skip
  '<td style="width: 5px;"></td>' skip
  '<td style="width: 40px;"></td>' skip
    
  '<td style="width: 20px;"></td>' skip
  '<td style="width: 30px;"></td>' skip
    
  '<td style="width: 40px;"></td>' skip
    
  '<td style="width: 5px;"></td>' skip
  '<td style="width: 20px;"></td>' skip
  '<td style="width: 5px;"></td>' skip
  '<td style="width: 10px;"></td>' skip
    
  '<td style="width: 30px;"></td>' skip
  '<td style="width: 40px;"></td>' skip
  '</tr>' skip

  '<tr><td colspan="15" style="text-align: center; font-weight: bold;">АКТ</td></tr>'
  '<tr><td colspan="15" style="text-align: center; font-weight: bold;">приема-передачи товара</td></tr>'
  '<tr><td colspan="15" style="text-align: center; font-weight: bold;">№' + string(buf_utd.DocumentNumber) + '</td></tr>'
  '<tr>' skip
  '<td colspan="4" style="text-align: center;">АЗК № ' + string(buf_utd.obj-code) + '</td>' skip
  '<td colspan="5" style="text-align: left;"></td>' skip
  '<td colspan="6" style="text-align: center;">' + v-date + '</td>' skip
  '</tr>' skip
  '<tr>' skip
  '<td colspan="4" style="text-align: center; vertical-align: top; font-size: 10pt;">место составления</td>' skip
  '<td colspan="5" style="text-align: left;"></td>' skip
  '<td colspan="6" style="text-align: center; vertical-align: top; font-size: 10pt;">дата составления</td>' skip
  '</tr>' skip
  '<tr>' skip
  '<td text_wrap="true" colspan="15" style="text-align: left; height: 25px;"></td>' skip
  '</tr>' skip
  '<tr>' skip
  '<td text_wrap="true" colspan="15" style="text-align: left;">Продавец (' + string(v-vendor-name) + ', ' + v-vendor-inn + ') и Покупатель (' + v-obj-info + ', Номер АЗК ' + string(buf_utd.obj-code) + '), в дальнейшем вместе именуемые «Стороны» и по отдельности «Сторона», составили настоящий Акт о нижеследующем:</td>' skip
  '</tr>' skip
  '<tr>' skip
  '<td text_wrap="true" colspan="15" style="text-align: left; height: 25px;"></td>' skip
  '</tr>' skip
  '<tr>' skip
  '<td text_wrap="true" colspan="15" style="text-align: left;">1. В соответствии с условиями Договора, заключенного между Сторонами № ' + v-contr-code + ' от ' + v-contr-date + ' по УПД ' + string(buf_utd.DocumentNumber) + ' от ' + v-utd-date + ' Продавец передает, а Покупатель принимает Товар следующего ассортимента и количества:</td>' skip
  '</tr>' skip

  .
put stream OutStr-html unformatted
  '<TR><TD colspan="15"></TD></TR>' skip
  '</thead>' skip
  '<tbody>' skip
  .
    
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" colspan="1" style="text-align: center; font-weight: bold;">№ п/п</TD>' skip
  '<TD text_wrap="true" colspan="5" style="text-align: center; font-weight: bold;">Наименование товара</TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold;">GTIN</TD>' skip
  '<TD text_wrap="true" colspan="1" style="text-align: center; font-weight: bold;">Кол-во пачек</TD>' skip
  '<TD text_wrap="true" colspan="4" style="text-align: center; font-weight: bold;">Кол-во блоков</TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold;">Серийные номера блоков</TD>' skip
  '</TR>' skip .

v-itog-level = 0 .
v-itog-unit = 0 .  
for each tt-utd no-lock by tt-utd.linenum:
  v-itog-level = v-itog-level + tt-utd.qnty-level .
  v-itog-unit = v-itog-unit + tt-utd.qnty-unit .
  run xmlchar-encode(tt-utd.ser-level, output ser-level) .
    
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(tt-utd.linenum) + '</TD>' skip
    '<TD text_wrap="true" colspan="5" style="text-align: left;">' + string(tt-utd.gds-name) + '</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">' + string (tt-utd.gtin) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string (tt-utd.qnty-unit) + '</TD>' skip
    '<TD text_wrap="true" colspan="4" style="text-align: center;">' + string (tt-utd.qnty-level) + '</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">' + ser-level + '</TD>' skip
    '</TR>'.                     
end.
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" colspan="7" style="text-align: left; font-weight: bold;">ИТОГО</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + string (v-itog-unit) + '</TD>' skip
  '<TD text_wrap="true" colspan="4" style="text-align: center; font-weight: bold;">' + string (v-itog-level) + '</TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center;"></TD>' skip
  '</TR>'
  .     
put stream OutStr-html unformatted
  '</tbody>' skip
  '<tfoot>' skip.
    
put stream OutStr-html unformatted
  '<TR style="height: 25px;">' skip
  '<TD text_wrap="true" colspan="8" style="text-align: left;">ПРОДАВЕЦ</TD>' skip
  '<TD text_wrap="true" colspan="7" style="text-align: left;">ПОКУПАТЕЛЬ</TD>' skip
  '</TR>'.                     
put stream OutStr-html unformatted
  '<TR style="height: 25px;">' skip
  '<TD text_wrap="true" colspan="8" style="text-align: left;">по доверенности № ____________ от _____________</TD>' skip
  '<TD text_wrap="true" colspan="7" style="text-align: left;">по доверенности № ____________ от _____________</TD>' skip
  '</TR>'.             
put stream OutStr-html unformatted
  '<TR style="height: 20px;">' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip      
  '</TR>'.                     
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; font-size: 10pt;">должность</TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-size: 10pt;">подпись</TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-size: 10pt;">Ф.И.О.</TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-size: 10pt;">должность</TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-size: 10pt;">подпись</TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; font-size: 10pt;">Ф.И.О.</TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip      
  '</TR>'.                              
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
  '<TD text_wrap="true" colspan="7" style="text-align: left;">М.П.</TD>' skip
  '</TR>'.    
      
put stream OutStr-html unformatted
  '</tfoot>' skip
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

procedure get-DD-Month-YYYY:
    
  /* Получение даты в формате "01 Января 2014г." */
  define input parameter p-dat-date as date no-undo.
  define output parameter p-str-date as character no-undo.

  define variable v-str-date  as character no-undo.
  define variable v-str-day   as character no-undo.
  define variable v-num-month as character no-undo.
  define variable v-str-month as character no-undo.
  define variable v-str-year  as character no-undo.

  v-str-date = string(p-dat-date).

  do: /* Получаем день в формате цифры, вида NN. */
    v-str-day = string(entry(1, v-str-date, "/")).
  end. /* Получаем день в формате цифры, вида NN. */

  do: /* Получаем прописью месяц */
    v-num-month = entry(2, v-str-date, "/").
    v-str-month = MonthNameRusCase(integer(v-num-month), 2).

  end. /* Получаем прописью месяц */

  do: /* Получаем год в формате цифры, вида "NNNN" */
    /*        v-str-year = entry(3, v-str-date, "/").*/
    v-str-year = string(year(p-dat-date)).
  end. /* Получаем год в формате цифры, вида "NNNN" */

  /* Получаем цифро-буквенную дату в одной строке */
  p-str-date = '" ' + v-str-day + ' "' + " " + v-str-month + " " + v-str-year + " г.".

end procedure.

 
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/
  define variable v-gds-name as character no-undo .
  define buffer buf_goods for ub.goods .
  
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if available (buf_goods) then v-gds-name = buf_goods.gds-name .
  RETURN v-gds-name.   /* Function return value. */

END FUNCTION.
