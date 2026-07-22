block-level on error undo, throw.
/*

$Revision: 45afebdf84b6, 1359, rls $
$Author: EShklyar $
$Date: Tue May 22 14:25:55 2018 +0300 $
$Workfile: r-corchk.p $
$Archive: rep/r-corchk.p $

Общий отчет по чекам транзакции

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
define variable vss-workfile    as character no-undo init "$Workfile: r-corchk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-corchk.p $":U .
define variable vss-description as character no-undo init "Общий отчет по чекам коррекции".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/html-conv.i }
{ gbl/prn-lib.i     }

define buffer buf_obj-list  for obj-list .
define buffer buf_clients   for ub.clients .
define buffer buf_chk-doc   for ub.chk-doc .
define buffer buf_shift-obj for ub.shift-obj .

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

define variable ii as integer no-undo .
define TEMP-TABLE tt-chk-doc-cor 
  field obj-code as integer
  field obj-type as character
  field income   as integer
  field expense  as integer
  field itog     as integer 
  field obj-name as character
  index pi
  is unique
  obj-code
  obj-type
  .  
define TEMP-TABLE tt-shift-obj like ub.shift-obj .


for each buf_obj-list no-lock:
if x-TOG-Shift = yes then do:

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
       
      find first tt-chk-doc-cor where tt-chk-doc-cor.obj-code = buf_chk-doc.obj-code and tt-chk-doc-cor.obj-type = buf_chk-doc.obj-type no-error .
      
      if not AVAILABLE (tt-chk-doc-cor) then 
      do:
        create tt-chk-doc-cor .
        BUFFER-COPY buf_chk-doc to tt-chk-doc-cor .
        assign
          tt-chk-doc-cor.obj-code = buf_chk-doc.obj-code
          tt-chk-doc-cor.obj-type = buf_chk-doc.obj-type
 
          .
      end.
      if buf_chk-doc.chk-type = integer({&income-corr}) then 
      do:
        assign
          tt-chk-doc-cor.income = tt-chk-doc-cor.income + 1
          tt-chk-doc-cor.itog   = tt-chk-doc-cor.itog + 1
          .
      end.
      else 
      do:
        assign
          tt-chk-doc-cor.expense = tt-chk-doc-cor.expense + 1
          tt-chk-doc-cor.itog    = tt-chk-doc-cor.itog + 1
          .
      end.    
    end.   

end.
else do:
  /*без смены*/
      for each buf_chk-doc no-lock 
      where buf_chk-doc.obj-code = buf_obj-list.obj-code 
      and buf_chk-doc.obj-type = buf_obj-list.obj-type
      and buf_chk-doc.chk-date >= x-Date-Start 
      and buf_chk-doc.chk-date <= x-Date-End
      and buf_chk-doc.out-code <> ?
      and (buf_chk-doc.chk-type = integer({&income-corr}) or buf_chk-doc.chk-type = integer({&expense-corr})):
      
      
      find first tt-chk-doc-cor where tt-chk-doc-cor.obj-code = buf_chk-doc.obj-code and tt-chk-doc-cor.obj-type = buf_chk-doc.obj-type no-error .
      if not AVAILABLE (tt-chk-doc-cor) then 
      do:
        create tt-chk-doc-cor .
        BUFFER-COPY buf_chk-doc to tt-chk-doc-cor .
        assign
          tt-chk-doc-cor.obj-code = buf_chk-doc.obj-code
          tt-chk-doc-cor.obj-type = buf_chk-doc.obj-type
 
          .
      end.
      if buf_chk-doc.chk-type = integer({&income-corr}) then 
      do:
        assign
          tt-chk-doc-cor.income = tt-chk-doc-cor.income + 1
          tt-chk-doc-cor.itog   = tt-chk-doc-cor.itog + 1
          .
      end.
      else 
      do:
        assign
          tt-chk-doc-cor.expense = tt-chk-doc-cor.expense + 1
          tt-chk-doc-cor.itog    = tt-chk-doc-cor.itog + 1
          .
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
    '<tr>' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 200px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '</tr>' skip
    .
                        
 
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" style="text-align: center;">Общий отчет о количестве кассовых чеков коррекции за период с ' + string(x-Date-Start,"99.99.99") + ' по ' + string(x-Date-End,"99.99.99") + ' </td>' skip
    '</tr>' skip   
    '</thead>' skip .
  
end.

procedure pr-line:
                      
                    
  put stream OutStr-html unformatted
    '<tbody>' skip
    '<TR>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">№</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">КОД АЗС</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">НАИМЕНОВАНИЕ</TD>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center; font-weight:bold; background-color: silver;">КОЛИЧЕСТВО КАССОВЫХ ЧЕКОВ КОРРЕКЦИИ</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ПРИХОД</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">РАСХОД</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ВСЕГО</TD>' skip
    '</TR>'skip       
           
    .
                            
  for each tt-chk-doc-cor:
    ii = ii + 1 .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">' + STRING (ii) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-chk-doc-cor.obj-code) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + pr-objname(tt-chk-doc-cor.obj-code) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-chk-doc-cor.income) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-chk-doc-cor.expense) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + STRING (tt-chk-doc-cor.itog) + '</TD>' skip
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

FUNCTION pr-objname RETURNS character
  ( INPUT p-obj-code AS integer) :

define variable v-obj-name as character no-undo .

find first ub.clients no-lock where ub.clients.obj-code = p-obj-code and ub.clients.obj-type = {&shop} no-error .
if AVAILABLE (ub.clients) then v-obj-name = ub.clients.obj-name .
 
RETURN v-obj-name.

END FUNCTION.
        
