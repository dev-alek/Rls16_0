block-level on error undo, throw.
/*

$Revision: 77640f64cf73, 2620, rls $
$Author: EShklyar $
$Date: Пн окт 19 09:22:02 2020 +0300 $
$Workfile: r-print-error.p $
$Archive: rep/r-print-error.p $

Печать ошибок по УПД

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

define variable vss-revision as character no-undo init "$Revision: 77640f64cf73, 2620, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пн окт 19 09:22:02 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-print-error.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-print-error.p $":U .
define variable vss-description as character no-undo init "Печать ошибок по УПД".
{ cmp/vssrevis.i }
{ str/temp_upd.i }

define input parameter pdoc-id  as integer no-undo .
define input parameter pdb-num  as integer no-undo .
define input parameter table for tt-utd-err . 
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/prn-lib.i }


FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer)  FORWARD.
  
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-period            as character no-undo .
define variable v-print-date        as character no-undo .
define variable ii                  as integer   no-undo .
define variable v-create-time     as character no-undo .
define variable v-create-date     as character no-undo .
define variable v-supp-name       as character no-undo .

define stream Out-Stream.
define stream OutStr-html.

define buffer buf_utd for ub.utd .
define buffer buf_clients for ub.clients .

do
    on error undo, return error return-value
    :

    /*Данные для шапки*/
    find first buf_utd no-lock where buf_utd.db-num = pdb-num and buf_utd.doc-id = pdoc-id no-error .
    find first buf_clients no-lock where buf_clients.obj-code = buf_utd.cli-code and 
                                         buf_clients.obj-type = buf_utd.cli-type no-error .
    if available (buf_clients) then v-supp-name = buf_clients.obj-name .                                            
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
        '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        .
    put stream OutStr-html unformatted
        '<tr class="set_columns">' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 250px;"></td>' skip
        '<td style="width: 500px;"></td>' skip
        '</tr>' skip
        .
                        
 
    put stream OutStr-html unformatted
        '<TR><TD colspan="4"></TD></TR>' skip
        '<TR>' skip
        '<TD colspan="4" style="font-weight: bold;">Ошибки по УПД № ' + string(buf_utd.DocumentNumber)+ " от " + string (buf_utd.DocumentDate) + '</TD>' skip
        '</TR>'skip
                                
        '<TR>' skip
        '<TD colspan="4">Поставщик: ' + string(v-supp-name) + '</TD>' skip
        '</TR>'skip

        .

    put stream OutStr-html unformatted
        '</thead>' skip
        '<tbody>' skip
        .
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">№ строки</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Код товара</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Название товара</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Текст ошибки</TD>' skip
        '</TR>'skip       
                    
        .
    for each tt-utd-err:

        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(tt-utd-err.LineNum) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-utd-err.gds-code <> ? then string(tt-utd-err.gds-code) + '</TD>' else ""  + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + GDSName(tt-utd-err.gds-code) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(tt-utd-err.descr) + '</TD>' skip
            '</TR>'skip     
            .
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
            
end .

function GDSName returns character 
        (input p-gds-code as integer):
/*------------------------------------------------------------------------------
        Purpose: Возвращает logical, топливный товар или нет
        Notes:
------------------------------------------------------------------------------*/    

define variable result as character no-undo.

find first ub.goods no-lock where ub.goods.gds-code = p-gds-code no-error .

if available (ub.goods) then result = ub.goods.gds-name .
else result = "" .
return result.

end function.

PROCEDURE get-report-num :

    define output parameter p-report-num as integer no-undo .
    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.

END PROCEDURE.

