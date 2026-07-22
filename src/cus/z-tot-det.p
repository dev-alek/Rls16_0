block-level on error undo, throw.
/*

$Revision: a8e2cf75ddf6, 2506, rls $
$Author: EShklyar $
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: z-tot-det.p $
$Archive: cus/z-tot-det.p $

Вывод Заказ с детализацией по объектам в HTML/EXCEL 

Автор: Шаланин Сергей
Дата создания: 
Author: Shalanin Sergey
Creation date: 
    
*/

define input  parameter parParentProc  as widget-handle no-undo .
define input  parameter p-ord-doc      as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .


define variable vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: z-tot-det.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/z-tot-det.p $":U .
define variable vss-description as character no-undo init "Заказ с детализацией по объектам".

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }
{ cmp/r-pril.i  new }
{ gbl/cur-time.i    }
{ rep/repfrm.i def  }
{ rep/f-fdec.i      }
{ gbl/paramls.i     }
{ cus/df-zakaz.i    }
{ gbl/dtm.i         }
{ cmp/library.i     }
{ gbl/clntattr.i    }
{ rep/fmtcli.i   }



{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i get }


  
define variable v-full-path-RepView   as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm   as character no-undo.   /* Полный путь к файлу отчёта */

define variable v-report-name         as character no-undo.         /* Наименование отчёта */
define variable base-type             as character no-undo .
define variable base-code             as integer   no-undo .
define variable g#report-num          as integer   no-undo .
define variable g#gds-engl            as logical   no-undo .
define variable g#log                 as logical   no-undo .


define variable p-cli-type            like ord-doc.cli-type no-undo .
define variable p-cli-code            like ord-doc.cli-code no-undo .
define variable p-doc-type            as character no-undo .
define variable p-doc-date            as date      no-undo .
define variable p-ship-date           like ord-doc.ship-date no-undo .
define variable p-ship-time           like ord-doc.ship-time no-undo .
define variable p-host-code           like ord-doc.host-code no-undo .
define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i p-obj-type p-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }

define buffer buf_ord-doc-rcv for ord-doc-rcv.
define buffer buf_ord-doc     for ord-doc.
define buffer buf_ord-line    for ord-line.
define buffer buf_cli-gds     for cli-gds.

define stream  OutStr-html .


run get-full-path-RepViewer(output v-full-path-RepView).   
  
run get-report-num in parParentProc(output g#report-num).

run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).

run create-file(v-file-name-rep-htm). 
v-report-name = "Заказ с детализацией по объектам".



find first buf_ord-doc no-lock where  buf_ord-doc.doc-code = p-ord-doc no-error .
if error-status :error then 
do:
    assign
        p-cli-type  = loc-cli-type
        p-cli-code  = loc-cli-code
        p-doc-type  = loc-doc-type
        p-doc-date  = doc-date
        p-ship-date = loc-date-ship
        p-host-code = v-cntxt-host-code-obj
        /* p-ship-time =  ( integer (entry(1,string(loc-time-ship,"hh:mm"),":"))   * 3600 ) +
                       ( integer (entry(2,string(loc-time-ship,"hh:mm"),":"))   * 60 ) */
        .

end.
else 
do:
    assign
        p-cli-type  = buf_ord-doc.cli-type
        p-cli-code  = buf_ord-doc.cli-code
        p-doc-type  = buf_ord-doc.doc-type
        p-doc-date  = buf_ord-doc.doc-date
        p-ship-date = loc-date-ship
        p-ship-time = buf_ord-doc.ship-time
        p-host-code = buf_ord-doc.host-code 
        .
    if p-cli-type = ? or p-cli-code = ? then 
    do:
        assign
            p-cli-type = loc-cli-type
            p-cli-code = loc-cli-code
            .
    end.
end.

    
{ rep/repfrm.i on 50 }
{ gbl/curobjdt.i p-obj-type p-obj-code to-day }
define variable p-name as character no-undo .
define buffer post-clients for clients.
define buffer sh-clients   for clients.


find first sh-clients no-lock where
    sh-clients.obj-type =   p-obj-type and
    sh-clients.obj-code =   p-obj-code no-error  . 
if error-status :error then next.
    
find first post-clients no-lock where
    post-clients.obj-type =   p-cli-type and
    post-clients.obj-code =   p-cli-code no-error  .
if error-status :error then next.
    
    
run proc-create-HTML(  input v-file-name-rep-htm).

run search-full-path-Report(input v-file-name-rep-htm).
run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm).
    
    
procedure proc-create-HTML:   

    define input parameter p-file-name-rep-htm as character no-undo.

    define variable p-ship-post as character no-undo.
 
    output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
              
        '      table ' + chr(123) + ' border-collapse: collapse; font-size:9pt; font-family:Calibri; table-layout: fixed; width: 540px; hight:  padding: 8px;  ' + chr(125) skip
        '      td ' + chr(123) ' border: 1px black solid; word-wrap:break-word; ' + chr(125) skip
        '      htm' skip
        '      .rotate ' + chr(123) skip
        '        -webkit-transform: rotate(-90deg);' skip
        '        -moz-transform: rotate(-90deg);' skip
        '        -ms-transform: rotate(-90deg);' skip
        '        -o-transform: rotate(-90deg);' skip
        '        transform: rotate(-90deg);' skip


        '        -webkit-transform-origin: 50% 50%;' skip
        '        -moz-transform-origin: 50% 50%;' skip
        '        -ms-transform-origin: 50% 50%;' skip
        '        -o-transform-origin: 50% 50%;' skip
        '        transform-origin: 50% 50%;' skip


        '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
        '          ' + chr(125) skip
        '            th' + ' ' + chr(123) skip
        '            border: 1px black solid;' skip
        '            word-wrap: break-word;' skip
        '          ' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        . 
    
    do:  /* Параметры "глобальной" таблицы отчёта */
        put stream OutStr-html unformatted
            ' <body>' skip
            '   <table name="'+  p-ord-doc  + '" fit_to_page="true" orientation="landscape" outline_below="false">' skip
            '     <thead>' skip
            '       <tr class="set_columns">' skip                          
            '         <td style="width: 100px; border: none;"></td>' skip    /*Код*/
            '         <td style="width: 110px; border: none;"></td>' skip      /*Наименование товара*/
            '         <td style="width: 110px; border: none;"></td>' skip    /* Единица измерения*/
            '         <td style="width: 180px; border: none;"></td>' skip   /*Количество*/
            '         <td style="width: 100px; border: none;"></td>' skip  /*Сумма без скидок*/
            '         <td style="width: 100px; border: none;"></td>' skip  /*Сумма со скидкой*/
            '         <td style="width: 100px; border: none;"></td>' skip  /*Количество чеков*/           
            '       </tr>' skip
            .
            
    end.


    do:
        put stream OutStr-html unformatted

            '<TR>'skip
            '<TD  colspan = "3" style="text-align: left;border: none">Заказ ' +   p-ord-doc  + " от " +   string( p-doc-date,"99/99/9999") + '</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip

            '<TR>'skip
            '<TD  colspan = "3" style="text-align: left;border: none">Покупатель: ' +  sh-clients.obj-name + '</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip

            '<TR>'skip
            '<TD  colspan = "3" style="text-align: left;border: none">Поставщик: ' +  post-clients.obj-name + '</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip

            '<TR>'skip
            '<TD  colspan = "3" style="text-align: left;border: none">Дата печати:  ' + string( today ,"99/99/9999") + '</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip

            '<TR>'skip
            '<TD  colspan = "2" style="text-align: left;border: none">Планируема дата доставки:  ' + if  p-ship-date <> ? then string(p-ship-date,"99/99/9999")  + '</td>' else " " + '</td>' skip
            '<TD style="text-align: left;border: none">     ' + if  p-ship-time <> ? then string(p-ship-time,"hh:mm")  + '</td>' else "?" + '</td>' skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip

            '     </thead>' skip
            . /* Точка для закрытия Put */
    end. /* b3 */
            
    do:  /* Шапка таблицы отчёта (видимой, как таблица) */
        put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr style="height: 60px;">' skip
            '         <th   style="background-color:#ffffcc; text-align: center;">Артикул</th>' skip
            '         <th   style="background-color:#ffffcc; text-align: center;">Тип производителя</th>' skip
            '         <th   style="background-color:#ffffcc; text-align: center;">Код производителя</th>' skip
            '         <th   style="background-color:#ffffcc; text-align: center;">Название товара</th>' skip
            '         <th   style="background-color:#ffffcc; text-align: center;">Артикул поставщика </th>' skip
            '         <th   style="background-color:#ffffcc; text-align: center;">Цена в валюте поставщика на баз.ед.изм.</th>' skip
            '         <th   style="background-color:#ffffcc; text-align: center;">Количество в баз.ед.изм</th>' skip
            '       </tr>' skip.

        output stream OutStr-html close.
    end. 
    
    output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        
    define variable v-cli as decimal no-undo.
    for each  buf_ord-line no-lock where  buf_ord-line.doc-code = p-ord-doc break by buf_ord-line.line-num  :
        find first goods no-lock where
            goods.artic     = buf_ord-line.artic     and
            goods.prod-type = buf_ord-line.prod-type and
            goods.prod-code = buf_ord-line.prod-code no-error .
        if error-status :error then next.
        find first clients no-lock where
            goods.prod-type = clients.obj-type and
            goods.prod-code = clients.obj-code no-error .
        if error-status :error then next.
          
        v-cli =  (buf_ord-line.price-cli / buf_ord-line.cli-base-rate).
        put stream OutStr-html unformatted
            '       <tr level="1">' skip
            '         <td  style="display: yes; text-align: right; font-weight: bold">' +  buf_ord-line.artic + '</td>' skip
            '         <td style="display: yes; text-align:  right; font-weight: bold">' +  buf_ord-line.prod-type  + '</td>' skip
            '         <td style="display: yes; text-align:  right; font-weight: bold">'  + string(buf_ord-line.prod-code)  + '</td>' skip
            '         <td text_wrap="true" style="display: yes; text-align:  right; font-weight: bold">'   +  goods.gds-name  + '</td>' skip
            '         <td style="display: yes; text-align:  right; font-weight: bold">'   + buf_ord-line.cli-art  + '</td>' skip
            '         <td style="display: yes; text-align:  right; font-weight: bold">'  +  string(v-cli, "->>>>>>>9.999") +  '</td>' skip
            '         <td style="display: yes; text-align:  right; font-weight: bold">'  +  string(buf_ord-line.qnty, "->>>>>>>9.99")  + '</td>' skip
            '       </tr>' skip
            .
                        
    end.                       
    do: 
        put stream OutStr-html unformatted
            '     </tbody>' skip
            '    </thead>' skip
            '   </table>' skip
            '  </body>' skip.
    end.
            
    for each buf_ord-doc-rcv where buf_ord-doc-rcv.doc-code =  p-ord-doc by buf_ord-doc-rcv.obj-code:
    
    
    
        find first sh-clients no-lock where
            sh-clients.obj-type =  buf_ord-doc-rcv.obj-type and
            sh-clients.obj-code =  buf_ord-doc-rcv.obj-code no-error  . 
        if error-status :error then next.
        find first post-clients no-lock where
            post-clients.obj-type =   buf_ord-doc-rcv.cli-type and
            post-clients.obj-code =  buf_ord-doc-rcv.cli-code no-error  .
        if error-status :error then next.
    
    
    
        run fmtcli-get-client in this-procedure (
            input buf_ord-doc-rcv.obj-type,
            input buf_ord-doc-rcv.obj-code
            ). 
    
        put stream OutStr-html unformatted
            ' <body>' skip
            '   <table name="' + buf_ord-doc-rcv.obj-type + string(buf_ord-doc-rcv.obj-code) + "-" +  buf_ord-doc-rcv.rcv-code '" fit_to_page="true" orientation="landscape" outline_below="false">' skip
        
            '     <thead>' skip
            '       <tr class="set_columns">' skip                 
            '         <td style="width: 100px; border: none;"></td>' skip    
            '         <td style="width: 110px; border: none;"></td>' skip    
            '         <td style="width: 110px; border: none;"></td>' skip    
            '         <td style="width: 180px; border: none;"></td>' skip  
            '         <td style="width: 100px; border: none;"></td>' skip  
            '         <td style="width: 100px; border: none;"></td>' skip  
            '         <td style="width: 100px; border: none;"></td>' skip   
            '       </tr>' skip
            .       
            
            
        do:
            put stream OutStr-html unformatted

                '<TR>'skip
                '<TD  colspan = "7" style="text-align: left;border: none">Объект: ' +  sh-clients.obj-name + '</TD>'skip
                '</TR>'skip

                '<TR>'skip
                '<TD  colspan = "7" style="text-align: left;border: none">Адрес: ' + v-fmtcli-full-addres   + '</TD>'skip
                '</TR>'skip


                '     </thead>' skip
                . /* Точка для закрытия Put */
        end. /* b3 */
            
        do:  /* Шапка таблицы отчёта (видимой, как таблица) */
            put stream OutStr-html unformatted
                '     <tbody>' skip
                '       <tr style="height: 60px;">' skip
                '         <th   style="background-color:#ffffcc; text-align: center;">Артикул</th>' skip
                '         <th   style="background-color:#ffffcc; text-align: center;">Тип производителя</th>' skip
                '         <th   style="background-color:#ffffcc; text-align: center;">Код производителя</th>' skip
                '         <th   style="background-color:#ffffcc; text-align: center;">Название товара</th>' skip
                '         <th   style="background-color:#ffffcc; text-align: center;">Артикул поставщика </th>' skip
                '         <th   style="background-color:#ffffcc; text-align: center;">Цена в валюте поставщика на баз.ед.изм.</th>' skip
                '         <th   style="background-color:#ffffcc; text-align: center;">Количество в баз.ед.изм</th>' skip
                '       </tr>' skip.
        end. 
            
        define buffer buf_ord-line-rcv for ord-line-rcv. 
        define variable v-cli-rcv as decimal no-undo .
        define variable v-cli-art as char no-undo.
        for each buf_ord-line-rcv no-lock where buf_ord-line-rcv.rcv-code = buf_ord-doc-rcv.rcv-code and  buf_ord-line-rcv.doc-code = buf_ord-doc-rcv.doc-code : 
            find first goods no-lock where
                goods.artic     = buf_ord-line-rcv.artic     and
                goods.prod-type = buf_ord-line-rcv.prod-type and
                goods.prod-code = buf_ord-line-rcv.prod-code no-error .
            if error-status :error then next.
            find first clients no-lock where
                goods.prod-type = clients.obj-type and
                goods.prod-code = clients.obj-code no-error .
            if error-status :error then next.
        
                      find first   buf_ord-line no-lock where  buf_ord-line.doc-code = buf_ord-line-rcv.doc-code  and buf_ord-line.artic = buf_ord-line-rcv.artic and  buf_ord-line-rcv.prod-type = buf_ord-line.prod-type
                      and buf_ord-line-rcv.prod-code = buf_ord-line.prod-code no-error.
                      if available buf_ord-line then do: 
                          v-cli-art  = buf_ord-line.cli-art.
                          end. 
                  
        
        
            v-cli-rcv =  (buf_ord-line.price-cli / buf_ord-line.cli-base-rate).

            put stream OutStr-html unformatted
                '       <tr level="1">' skip
                '         <td  style="display: yes; text-align: right; font-weight: bold">' +  buf_ord-line-rcv.artic + '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">' +  buf_ord-line-rcv.prod-type  + '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'  + string(buf_ord-line-rcv.prod-code)  + '</td>' skip
                '         <td text_wrap="true" style="display: yes; text-align:  right; font-weight: bold">'   +  goods.gds-name  + '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">' + v-cli-art  + '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'  +  string(v-cli-rcv, "->>>>>>>9.999")  + '</td>' skip 
                '         <td style="display: yes; text-align:  right; font-weight: bold">'  +  string(buf_ord-line-rcv.qnty, "->>>>>>>9.999") + '</td>' skip
                '       </tr>' skip
                .
        end.                       

        do:   
            put stream OutStr-html unformatted  
                '</thead>' skip
                '     </tbody>' skip
                
                '</table>' skip
                '</body>' skip
                .
        end.
    end.
     
    do: 
        put stream OutStr-html unformatted  
            ' </html>' skip
            . /* Точка для закрытия Put */
        output stream OutStr-html close.
    end.   
end procedure.        
            
            
            
        
      
procedure define-full-path-Report:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
    /* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

end procedure.


procedure create-file:              /* СоздЛюбогоФайлаНаДиске(input полный_путь_с_именем) */
    /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.


procedure Report-Viewer:            /* Запуск на выполнение RV (input Полный_путь_имя_файла_RV, input Полный_путь_имя_файла_отчHTML) */
    /* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

    os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).

end procedure.

procedure get-full-path-RepViewer:  /* Получение полного пути к исполняемому файлу RV.exe (output Полный_путь_имя_файла_RV.exe) */
    /* Получение полного пути к exe-файлу просмотровщика отчётов */
    define output parameter p-fill-path-RepView as character no-undo.

    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.



procedure search-full-path-Report:  /* Только проверка, есть файл отчёта HTML или нет(тогда вывод сбщ-ош) */
    /* Поиск файла */
    define input parameter p-file-name as character no-undo.

    if search(p-file-name) = ? then
    do:
        message "Не найден файл отчёта: " p-file-name view-as alert-box error.
    end.
    else
    do:
        p-file-name = search(p-file-name).
    end.

end procedure.        
            

