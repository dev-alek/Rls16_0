block-level on error undo, throw.
/*

$Revision: 6f0fa439fecf, 2278, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:24:02 2019 +0300 $
$Workfile: r-TSDVersion.p $
$Archive: rep/r-TSDVersion.p $

Отчет по версионности ТСД

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

define variable vss-revision    as character no-undo init "$Revision: 6f0fa439fecf, 2278, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:02 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-TSDVersion.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-TSDVersion.p $":U .
define variable vss-description as character no-undo init "Отчет по версионности ТСД".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i      }
{ gbl/cur-time.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }

define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-list-obj          as character no-undo .
define variable v-print-date        as character no-undo .

FUNCTION cli-name RETURNS character
    (cli-code as integer, cli-type as character ) FORWARD.
    
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
  
   
  /*Дата и время печати*/
  DEFINE VARIABLE v-today as date    no-undo .
  DEFINE VARIABLE v-time  as integer no-undo .
  run cur-time in this-procedure (
    output v-today
    , output v-time
    ).
  v-print-date = "Дата формирования: " + string (v-today,"99.99.9999") + ", время: " + string(truncate (v-time / 3600, 0)) + ":" + string((v-time modulo 3600) / 60,"99")  + ":" + string((v-time modulo 3600) / 360,"99").     
 
  for each obj-list no-lock:
    if v-list-obj = "" then v-list-obj = string(obj-list.obj-code).
    else v-list-obj = v-list-obj + ", " + string(obj-list.obj-code).
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
                        
                        
    put stream OutStr-html unformatted
      '<body>' skip
      /*Первая таблица*/
      '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
      '<thead>' skip
      .
    put stream OutStr-html unformatted
      '<tr class="set_columns">' skip
      '<td style="width: 120px;"></td>' skip
      '<td style="width: 120px;"></td>' skip
      '<td style="width: 120px;"></td>' skip
      '<td style="width: 120px;"></td>' skip
      '</tr>' skip
      .
                        
 
    put stream OutStr-html unformatted
      '<TR><TD colspan="4"></TD></TR>' skip
      '<TR>' skip
      '<TD colspan="4" style="font-weight: bold; text-align: center;">Отчет по версионности ТСД</TD>' skip
      '</TR>'skip
                                
      '<TR>' skip
      '<TD colspan="4">' + "АЗC:  " + v-list-obj + " маг" + '</TD>' skip
      '</TR>'skip

      '<TR>' skip
      '<TD colspan="4">' + v-print-date + '</TD>' skip
      '</TR>'skip
      .

    put stream OutStr-html unformatted
      '</thead>' skip
      '<tbody>' skip
      .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="font-weight: bold; text-align: center;">АЗС</TD>' skip
      '<TD text_wrap="true" style="font-weight: bold; text-align: center;">Версия ПО</TD>' skip
      '<TD text_wrap="true" style="font-weight: bold; text-align: center;">ID устройства</TD>' skip
      '<TD text_wrap="true" style="font-weight: bold; text-align: center;">Дата и время последнего подключения устройства</TD>' skip
      '</TR>'skip       
                    
      .
    
    for each ub.Code no-lock where ub.Code.parent = "TSDversion" by ub.Code.misc2:

      put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" style="text-align: center;">' + cli-name(integer(ub.Code.misc2), ub.Code.misc3) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if ub.Code.misc1 = ? then "" else ub.Code.misc1 + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + ub.Code.code + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + ub.Code.misc4 + '</TD>' skip
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


FUNCTION cli-name RETURNS character
    (cli-code as integer, cli-type as character ):
  
    define variable v-cli-name as character no-undo.
    find first ub.clients no-lock where ub.clients.obj-code = cli-code and
        ub.clients.obj-type = cli-type no-error .
    if available (ub.clients) then 
    do:
        v-cli-name = ub.clients.obj-name .
    end.
    return v-cli-name.
  
end function.                                        

