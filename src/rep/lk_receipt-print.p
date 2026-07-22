/*

$Revision: c96af91888ad, 3081, rls $
$Author: SSlivenko $
$Date: Пт авг 05 19:16:26 2022 +0300 $
$Workfile: LK_RECEIPT-print.p $
$Archive: rep/LK_RECEIPT-print.p $

Акт-приема передачи товара

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
block-level on error undo, throw.

define variable vss-revision    as character no-undo init "$Revision: c96af91888ad, 3081, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:26 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: LK_RECEIPT-print.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/LK_RECEIPT-print.p $":U .
define variable vss-description as character no-undo init "Акт-приема передачи товара".
{ cmp/vssrevis.i }

define input parameter parparentproc    as widget-handle  no-undo.
define input parameter p-rec-list as character no-undo .

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ gbl/objsrv.i }
{ str/utd-attr.i }
{ utl/gtin.i }

&global-define month-list-for-date 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U
/* Для вызова функции конвертации даты к виду: "01 Января 2014г" */
&scop f-l MonthNameRusCase

  { gbl/std-func.i {&f-l} }
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-files as character no-undo .
define variable v-date              as character no-undo .
define variable v-utd-date          as character no-undo .
define variable ii                  as integer   no-undo .
def    var      Marking             as class     mark no-undo .
  
define buffer buf_utd               for ub.utd .
define buffer buf_utd-err           for ub.utd-err .
define buffer buf_utd-lines         for ub.utd-lines .

do
on error undo, return error return-value
:
  /*Сбор данных*/
  run get-DD-Month-YYYY(date(today), output v-date) .
  do ii = 1 to num-entries(p-rec-list) :
    run printDoc (input entry(ii, p-rec-list)) .
  end .
  
  v-files = trim(v-files, " ") .
  
  run prn-lib-reportviewer in this-procedure (
      input this-procedure
      ,input v-files
      ,input "" 
      ) no-error.
  if error-status:error then
  do:
      message return-value view-as alert-box.
      return .
  end.

end .

procedure printDoc :
  define input parameter p-row-str as character no-undo .
  
  define variable v-reason as character no-undo .
    
  find first buf_utd no-lock where rowid(buf_utd) = to-rowid(p-row-str) no-error .
  if not available (buf_utd) then 
  do:
    return .
  end.  
  
  v-reason = getattrUtd(input buf_utd.db-num, input buf_utd.doc-id, input "LK_RECEIPT_Action") .
  
  case v-reason :
    when "PRODUCTION_USE" then v-reason = "Использование для производственных целей" .
    when "LOSS" then v-reason = "Утрата" .
    when "DESTRUCTION" then v-reason = "Уничтожение" .
    otherwise do :
      v-reason = "Неизвестна" .
    end .
  end case .

  run get-DD-Month-YYYY(buf_utd.DocumentDate, output v-utd-date) .
  
      
  /*печать*/
  run get-report-num (output p-report-id).
      
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html" .   
  v-files = v-files + session:temp-directory + string(p-report-id) + ".html " .

                        
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
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 450px;"></td>' skip
    '<td style="width: 200px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '</tr>' skip
  . 
  
  if buf_utd.documentExt > ""
  then do :
    put stream OutStr-html unformatted
      '<tr><td colspan="4" style="text-align: left; font-weight: bold;">Вн. № ' + string(buf_utd.documentExt) + '</td></tr>'
    .
  end .
  put stream OutStr-html unformatted
    '<tr><td colspan="4" style="text-align: left; font-weight: bold;">Первичный документ ' + string(buf_utd.doc-code) + '</td></tr>'
    '<tr><td colspan="4" style="text-align: left; font-weight: bold;">Закрыт ' + string(v-utd-date) + '</td></tr>'
    '<tr><td colspan="4" style="text-align: left; font-weight: bold;">Причина: ' + string(v-reason) + '</td></tr>'
  .
  
  if can-find(first buf_utd-err no-lock where buf_utd-err.db-num = buf_utd.db-num and buf_utd-err.doc-id = buf_utd.doc-id)
  then do :
    put stream OutStr-html unformatted
      '<tr><td colspan="4" style="text-align: left; font-weight: bold;">Ошибки:</td></tr>'
    .
  end .
  
  for each buf_utd-err no-lock where buf_utd-err.db-num = buf_utd.db-num
                                 and buf_utd-err.doc-id = buf_utd.doc-id
  :
    put stream OutStr-html unformatted
      '<tr><td colspan="4" style="text-align: left;">' + buf_utd-err.CheckObj + '</td></tr>'
    .
  end .
  
  put stream OutStr-html unformatted
    '<tr><td colspan="4"></td></tr>'
    '</thead>' skip
    '<tbody>' skip
  .                               
      
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">№ п/п</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Наименование товара</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">GTIN</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Количество</TD>' skip
    '</TR>' skip
  .
  
  for each buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd.db-num
                                   and buf_utd-lines.doc-id = buf_utd.doc-id
                                   by buf_utd-lines.linenum
  :
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: left;">' + string(buf_utd-lines.linenum) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: left;">' + string(buf_utd-lines.GdsName) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: left;">' + string (buf_utd-lines.ProductCode) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right;">' + string (buf_utd-lines.Quantity) + '</TD>' skip
      '</TR>'
    .
  end .    
        
  put stream OutStr-html unformatted
    '</tbody>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
  .
                              
  output stream OutStr-html close.  
  
end procedure .   


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
