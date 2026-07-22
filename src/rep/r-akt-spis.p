block-level on error undo, throw.
/*
$Revision: $
$Author: EShklyar $ Shalanin Sergey
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: r-akt-spis.p $
$Archive: rep/r-akt-spis.p $

акт списания нефтепродукта , отпущенного на технологические нужды АЗС/АЗК.


Автор: Шаланин Сергей
Дата создания: 08.06.2017
Author: Shalanin Sergey
Creation date: 08/06/17
*/




define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-akt-spis.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-akt-spis.p $":U .
define variable vss-description as character no-undo init "акт списания нефтепродукта".
{ cmp/vssrevis.i }
&scop f-l MonthNameRusCase
{ gbl/std-func.i {&f-l} }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ rep/w-rep.i    }
{ gbl/paramls.i  }
{ ref/gds-attr.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }



/*define input parameter p-mainmenu-handle    as handle           no-undo.*/
define input parameter p-doc-code as char no-undo.

define buffer t-doc for trn-doc.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .

define stream  macr_excel .
define stream  out-stream .
define stream OutStr-html.


/*define temp-table spis-neft no-undo*/
/*field gds-code as integer          */
/*field TRk as integer               */
/*field gds-name as integer          */
/*field chk-type as integer          */
/*field density as decimal           */
/*field mass-total as decimal        */
/*index primary pi  gds-code trk.    */
define variable v-month-rus as character no-undo.
define variable v-DD-Month-YYYY as character no-undo.
find first chk-doc no-lock
    where chk-doc.doc-code = p-doc-code no-error.

      find first clients where clients.obj-code = chk-doc.obj-code and clients.obj-type = chk-doc.obj-type no-lock no-error.

FOR EACH chk-gds NO-LOCK Where
    chk-gds.doc-code = chk-doc.doc-code by chk-gds.line-num:
    FIND FIRST bar-code No-LOCK WHERE
        bar-code.b-code = chk-gds.b-code NO-ERROR.
    IF AVAIL bar-code then 
    do:
        FIND FIRST goods NO-LOCK WHERE
            goods.gds-code = bar-code.gds-code NO-ERROR.

 run get-DD-month-YYYY(input chk-doc.chk-date, output v-DD-Month-YYYY).
        

        /*run get-full-path-RepViewer(output v-full-path-RepView).*/
  

        /*run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).*/
        /*                                                                            */
        /*run create-file(v-file-name-rep-htm).                                       */

        run get-report-num (output p-report-id).
    
        v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html". 
     
     
     
        output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
        put stream OutStr-html unformatted
            "<!DOCTYPE HTML>" skip
            ' <html>' skip
            '  <head>' skip
            '   <meta charset="utf-8">' skip
            '    <style type="text/css">' skip
              
            '      table ' + chr(123) + ' border-collapse: collapse; font-size:12pt;  table-layout: fixed; width: 830px;hight: padding: 1px;' + chr(125) skip
            '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
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
    
            '     <body>' skip
            '  <A NAME="AKT"><H1><EM></EM></H1></A>' skip
            '<TABLE name= ' + string(goods.gds-code) + '  fit_to_page="true" orientation="Portrait">'skip
/*            '  <COLGROUP SPAN="10" WIDTH="66">'skip */
/*            ' <COLGROUP WIDTH="16">'skip            */
/*            '<COLGROUP WIDTH="110">'skip            */
/*            '<COLGROUP SPAN="3" WIDTH="66">'skip    */
/*            '<COLGROUP WIDTH="133"></COLGROUP>' skip*/

            '<TR>'skip
/*            '<TD  style="width: 59px; text-align: left;border: none;border-bottom: 1px solid black;"></TD>'skip*/
            '<TD colspan="3" style="text-align: center;border: none;border-bottom: 1px solid black;"> ' + clients.obj-name  + '</TD>'skip
/*            '<TD style="width: 30px; text-align: left;border: none;border-bottom: 1px solid black;"></TD>'skip*/
            '<TD style="width: 90px; text-align: left;border: none;"></TD>'skip
            '<TD style="width: 31px; text-align: left;border: none;"></TD>'skip
            '<TD style="width: 83px; text-align: left;border: none;"></TD>'skip
            '<TD style="width: 36px; text-align: left;border: none;"></TD>'skip
            '<TD style="width: 40px; text-align: left;border: none;"></TD>'skip
            '<TD style="width: 140px; text-align: left;border: none;"></TD>'skip
            '<TD style="width: 28px; text-align: left;border: none;"></TD>'skip
            '<TD style="width: 42px; text-align: left;border: none;"></TD>'skip
            '<TD style="width: 21px; text-align: left;border: none;"></TD>'skip
            '<TD style="width: 81px; text-align: left;border: none;"></TD>'skip
            '<TD style="width: 35px; text-align: left;border: none;"></TD>'skip
            
            '</TR>'skip
            
            '<TR>'skip
            '<TD colspan="3" style="text-align: center; font-size:7pt; border:top; border:none">АЗС/АЗК</TD>'skip
            '<TD colspan="11" style="text-align: left;border: none"></TD>'skip 
            '</TR>'skip
    
               
            '<TR>'skip
                        '<TD   style="width: 59px;text-align: left;border: none"></TD>'skip
                        '<TD   style="width: 96px;text-align: left;border: none"></TD>'skip
                        '<TD   style="width: 30px;text-align: left;border: none"></TD>'skip
            
            '<TD  colspan="4" style="text-align: left;border: none"></TD>'skip
            '<TD colspan="7" style="text-align: center;border: none">Утверждаю</TD>'skip 
            '</TR>'skip
    
            '<TR>'skip
            '<TD  colspan="7" style="text-align: left;border: none"></TD>'skip
            '<TD colspan="7" style="text-align: left;border: none"></TD>'skip 
            '</TR>'skip
    
            '<TR>'skip
            '<TD  colspan="7" style="text-align: left;border: none"></TD>'skip
            '<TD HEIGHT="17" colspan="7" style="text-align: left;border: none;border-bottom: 1px solid black;">            </TD>'skip 
            '</TR>'skip
    
            '<TR>'skip
            '<TD  colspan="7" style="text-align: left;border: none"></TD>'skip
            '<TD  colspan="7" style="text-align: center;border: none;border-top: 1px solid black;font-size:6pt;">Должность, Фамилия, И.О.</TD>'skip 
            '</TR>'skip
    
            '<TR>'skip
            '<TD  colspan="7" style="text-align: left;border: none"></TD>'skip
            '<TD HEIGHT="17" colspan="7" style="text-align: left;border: none;border-bottom: 1px solid black;"></TD>'skip 
            '</TR>'skip
    
            '<TR>'skip
            '<TD  colspan="7" style="text-align: left;border: none"></TD>'skip
            '<TD colspan="7" style="text-align: center;border: none;border-top: 1px solid black;font-size:6pt;">руководителя ОГ</TD>'skip 
            '</TR>'skip
    

            '<TR>'skip
            '<TD  colspan="7" style="text-align: left;border: none"></TD>'skip
/*            '<TD style="text-align: left;border: none;"> " </TD>'skip*/
            '<TD  colspan = "7" style="text-align: center;border: none;border-botom: 1px solid black;"> ' + v-DD-Month-YYYY  +  '</TD>'skip 
            
            '</TR>'skip
    
            '<TR>'skip
            '<TD  colspan="14" style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
   
            '<TR>'skip
            '<TD  colspan="14" style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
   
    
  
            '<TR>'skip
            '<TD colspan = "14" style="font-weight: bold; text-align: center; border: none"> АКТ</TD>'skip
            '</TR>'skip
   
            
    
            '<TR>'skip
            '<TD colspan="14" style="font-weight: bold; text-align: center; border: none"> списание нефтепродукта, отпущенного на технологические нужды АЗС/АЗК</TD>'skip
            '</TR>'skip
           
        '<TR>'skip
        '<TD colspan="3" style="text-align: left;border: none"></TD>'skip     
        '<TD style="text-align: right;border: none">от</TD>'skip     
        '<TD colspan = "5" style="text-align: left;border: none;"> ' + v-DD-Month-YYYY  + '</TD>'skip     
        '<TD style="text-align: right;border: none"></TD>'skip     
        '<TD style="text-align: right;border: none"></TD>'skip     
        '<TD style="text-align: right;border: none"></TD>'skip                                          
        '<TD style="text-align: right;border: none"></TD>'skip     
        '<TD style="text-align: right;border: none"></TD>'skip     
                                                             
        '</TR>'skip    
    
      
             '<TR>'skip
            '<TD HEIGHT="17" colspan="14" style="text-align: left;border: none;"></TD>'skip               
            '</TR>'skip
          
            
             '<TR>'skip
            '<TD HEIGHT="17" colspan="14" style="text-align: left;border: none;"></TD>'skip               
            '</TR>'skip
          
          
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border: none;">Комиссия в составе:</TD>'skip      
            '<TD colspan="9" style="text-align: left;border: none;"></TD>'skip              
            '</TR>'skip    
        
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border:none;">Председатель комиссии:</TD>'skip     
            '<TD colspan="9" style="text-align: left;border:none;border-bottom: 1px solid black;"></TD>'skip               
            '</TR>'skip  
    
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border: none"></TD>'skip     
            '<TD colspan="9" style="text-align: center;border: none;border-top: 1px solid black;font-size:6pt;">должность,фамилия, И.О.</TD>'skip               
            '</TR>'skip        
                 
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border: none;">Члены комиссии:</TD>'skip     
            '<TD colspan="9" style="text-align: left;border: none;border-bottom: 1px solid black;"></TD>'skip               
            '</TR>'skip            
         
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border: none"></TD>'skip     
            '<TD colspan="9" style="text-align: center;border: none;border-top: 1px solid black;font-size:6pt;">должность,фамилия, И.О.</TD>'skip               
            '</TR>'skip        
          
            '<TR>'skip
            '<TD colspan="14" style="text-align: left;border: none"></TD>'skip    
            '</TR>'skip        
          
             '<TR>'skip
            '<TD HEIGHT="17" colspan="14" style="text-align: left;border: none;"></TD>'skip               
            '</TR>'skip
          
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border: none">составили настоящий акт, о том что </TD>'skip     
/*            '<TD style="text-align: right;border:none"> " </TD>'skip*/
            '<TD colspan= "7" style="text-align: center;border: none;border-bottom: 1px solid black;">'   + v-DD-Month-YYYY  + ' </TD>'skip         
/*            '<TD style="text-align: center;border:none"> " </TD>'skip                               */
/*            '<TD style="text-align: center;border: none;border-bottom: 1px solid black;"> </TD>'skip*/
/*            '<TD style="text-align: right;border:none">20</TD>'skip                                 */
/*            '<TD style="text-align: center;border: none;border-bottom: 1px solid black;"> </TD>'skip*/
/*            '<TD style="text-align: center;border:none"> г. </TD>'skip                              */
            '<TD style="text-align: right;border:none">через ТРК</TD>'skip  
            '<TD style="text-align: center;border:none;border-bottom: 1px solid black;"> №  ' + string(chk-gds.pump) + '</TD>'skip  
          
            '</TR>'skip  
    
    
            '<TR>'skip
            '<TD colspan="4" style="text-align: left;border: none">был отпущен нефтепродукт</TD>'skip     
            '<TD colspan= "3"style="text-align: center;border: none;border-bottom: 1px solid black;"> ' + goods.gds-name + ' </TD>'skip 
            '<TD colspan="3" style="text-align: left;border: none">в количестве</TD>'skip     
            '<TD colspan= "4"style="text-align: center;border: none;border-bottom: 1px solid black;">' + string(chk-gds.doc-qnty) + '  л. </TD>'skip 
            '</TR>'skip  
     
     
            '<TR>'skip
            '<TD colspan="4" style="text-align: left;border: none"></TD>'skip     
            '<TD colspan="3" style="text-align: center;border: none;border-top: 1px solid black;font-size:6pt;">наименование нефтепродукта</TD>'skip   
            '<TD colspan="7" style="text-align: left;border: none"></TD>'skip     
                       
            '</TR>'skip        
    
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border: none;">на собственные технологические нужды АЗС/АЗК:</TD>'skip     
            '<TD colspan="9" style="text-align: left;border: none;border-bottom: 1px solid black;"> ТехПролив</TD>'skip               
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="17" colspan="14" style="text-align: left;border: none;border-bottom: 1px solid black;"></TD>'skip               
            '</TR>'skip
    
            '<TR>'skip
            '<TD colspan="14" style="text-align: center;border: none;border-top: 1px solid black;font-size:6pt;">назначение расхода</TD>'skip   
            '</TR>'skip        
    
            '<TR>'skip
            '<TD colspan="14" style="text-align: center;border: none;"></TD>'skip   
            '</TR>'skip        
    
        '<TR>'skip
        '<TD HEIGHT="17" colspan="14" style="text-align: left;border: none;"></TD>'skip               
        '</TR>'skip
    
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border: none;">Плотность отпущенного нефтепродукта:</TD>'skip     
            '<TD colspan="5" style="text-align: left;border: none;border-bottom: 1px solid black;">' +  string( 1000 * chk-gds.density , "->>>>>>>>>>>>>>>>9.9999" ) + '</TD>'skip     
            '<TD colspan="4" style="text-align: left;border: none;">кг/м<sup>3</sup></TD>'skip    
            '</TR>'skip
    
    
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border: none;">Масса отпущенного нефтепродукта:</TD>'skip     
            '<TD colspan="5" style="text-align: left;border: none;border-bottom: 1px solid black;"> ' + string( (chk-gds.doc-qnty * chk-gds.density) , "->>>>>>>>>>>>>>>>9.999" )  + '</TD>'skip     
            '<TD colspan="4" style="text-align: left;border: none;">кг</TD>'skip    
            '</TR>'skip
    
        '<TR>'skip
        '<TD HEIGHT="17" colspan="14" style="text-align: left;border: none;"></TD>'skip               
        '</TR>'skip
            
            '<TR>'skip 
            '<TD colspan="14" style="text-align: left;border: none;">Отпущенный нефтепродукт израсходован полностью.</TD>'skip               
            '</TR>'skip
            
        '<TR>'skip
        '<TD HEIGHT="17" colspan="14" style="text-align: left;border: none;"></TD>'skip               
        '</TR>'skip
    
            '<TR>'skip
            '<TD colspan="14" style="text-align: left;border: none;">Вышеуказанный расход предлагается списать на собственные нужды Общества.</TD>'skip               
            '</TR>'skip
    
     '<TR>'skip
            '<TD HEIGHT="17" colspan="14" style="text-align: left;border: none;"></TD>'skip               
            '</TR>'skip
    
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border:none;">Председатель комиссии:</TD>'skip     
            '<TD colspan="2" style="text-align: left;border:none;border-bottom: 1px solid black;"></TD>'skip 
            '<TD  style="text-align: left;border:none;"></TD>'skip 
            '<TD colspan="2" style="text-align: left;border:none;border-bottom: 1px solid black;"></TD>'skip 
            '<TD  style="text-align: left;border:none;"></TD>'skip 
            '<TD colspan="2" style="text-align: left;border:none;border-bottom: 1px solid black;"></TD>'skip        
            '</TR>'skip  
      
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border:none;"></TD>'skip     
            '<TD colspan="2" style="text-align: center;border:none;border-top: 1px solid black;font-size:6pt;">должность</TD>'skip 
            '<TD  style="text-align: left;border:none;"></TD>'skip 
            '<TD colspan="2" style="text-align: center;border:none;border-top: 1px solid black;font-size:6pt;">подпись</TD>'skip 
            '<TD  style="text-align: left;border:none;"></TD>'skip 
            '<TD colspan="2" style="text-align: center;border:none;border-top: 1px solid black;font-size:6pt;">расшифровка подписи</TD>'skip        
            '</TR>'skip  
      
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border:none;">Члены комиссии:</TD>'skip     
            '<TD colspan="2" style="text-align: left;border:none;border-bottom: 1px solid black;"></TD>'skip 
            '<TD  style="text-align: left;border:none;"></TD>'skip 
            '<TD colspan="2" style="text-align: left;border:none;border-bottom: 1px solid black;"></TD>'skip 
            '<TD  style="text-align: left;border:none;"></TD>'skip 
            '<TD colspan="2" style="text-align: left;border:none;border-bottom: 1px solid black;"></TD>'skip        
            '</TR>'skip  
      
            '<TR>'skip
            '<TD colspan="5" style="text-align: left;border:none;"></TD>'skip     
            '<TD colspan="2" style="text-align: center;border:none;border-top: 1px solid black;font-size:6pt;">должность</TD>'skip 
            '<TD  style="text-align: left;border:none;"></TD>'skip 
            '<TD colspan="2" style="text-align: center;border:none;border-top: 1px solid black;font-size:6pt;">подпись</TD>'skip 
            '<TD  style="text-align: left;border:none;"></TD>'skip 
            '<TD colspan="2" style="text-align: center;border:none;border-top: 1px solid black;font-size:6pt;">расшифровка подписи</TD>'skip        
            '</TR>'skip  
    
            .
        do: 
            put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
                . /* Точка для закрытия Put */
            output stream OutStr-html close.
        end. 
    end.
end.
        
/*       do:                                     */
/*             put stream OutStr-html unformatted*/
/*            '</tbody>'                         */
/*            '   </table>' skip                 */
/*            '  </body>' skip.                  */
/*    end.                                       */
/*                                               */
          
                 
run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).
/*    end.*/
 
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


procedure create-file:              /* СоздЛюбогоФайлаНаДиске(input полный_путь_с_именем) */
    /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.


/*procedure define-full-path-Report:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */*/
/*    /* Получение полного пути к отчёту html */                                                                                      */
/*    define input parameter p-rep-num as integer no-undo.                                                                            */
/*    define output parameter p-file-name-rep-htm as character no-undo.                                                               */
/*                                                                                                                                    */
/*    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".                                        */
/*                                                                                                                                    */
/*end procedure.                                                                                                                      */


procedure Report-Viewer:            /* Запуск на выполнение RV (input Полный_путь_имя_файла_RV, input Полный_путь_имя_файла_отчHTML) */
    /* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

    os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).

end procedure.                
                 
                 

                 
PROCEDURE get-report-num :

    define output parameter p-report-num as integer no-undo .

    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.

END PROCEDURE.