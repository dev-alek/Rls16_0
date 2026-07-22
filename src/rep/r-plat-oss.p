block-level on error undo, throw.
/*------------------------------------------------------------------------
$Revision: $
$Author: $
$Date: $
$Workfile: r-plat-oss.p $
$Archive: rep/r-plat-oss.p $

Отчет Платежи ОСС

Автор: Кривошеин Александр Николаевич
Дата создания: 23/11/14
Author: Krivoshein Alexander
Creation date: 23/11/14

  ----------------------------------------------------------------------*/

def var vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-plat-oss.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-plat-oss.p $":U .
def var vss-description as character no-undo init "Печать Платежей ОСС".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  } /* Внутри вложен { cmp/obj-list.i {1}}, в котором формируется таблица obj-list. */
{ str/trdcalib.i }
{ gbl/attr-lib.i }
{ ref/gds-attr.i }
{ trg/factord.i  }
{ gbl/paramls.i  }
{ rep/fmtcli.i   }
{ cmp/r-pril.i new }
{ ref/extclass.i }
/*===================================================================================================================*/

define input parameter parParentProc as handle no-undo.
DEFINE INPUT PARAMETER v-operator AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER v-classified AS INTEGER NO-UNDO.

&glob check-no-error no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
&glob check-error if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).

define stream Out-Stream.
define stream OutStr-html.

DEFINE BUFFER buf_shift-obj_from FOR ub.shift-obj.
DEFINE BUFFER buf_shift-obj_till FOR ub.shift-obj.
DEFINE BUFFER buf_shift-obj      FOR ub.shift-obj.
DEFINE BUFFER buf_chk-doc        FOR ub.chk-doc.
DEFINE BUFFER buf_goods-attr     FOR ub.goods-attr.
DEFINE BUFFER buf_chk-gds-pay    FOR ub.chk-gds-pay.
DEFINE BUFFER buf_bar-code       FOR ub.bar-code.
DEFINE BUFFER buf_chk-gds-attr   FOR ub.chk-gds-attr.
DEFINE BUFFER buf_ext-classif    FOR ub.ext-classif.

DEFINE TEMP-TABLE tt-ref NO-UNDO
field obj-name like obj-list.obj-name
    FIELD obj-code LIKE obj-list.obj-code
    field obj-type like obj-list.obj-type
    FIELD oss-name LIKE ub.ext-classif.charkey_one
    FIELD chk-num AS INTEGER
    FIELD chk-sum AS DECIMAL
    field tot-r-b as decimal
    .
define variable v-choice-obj as character no-undo.
DEFINE VARIABLE v-attr-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-attr-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-oss-name AS CHARACTER NO-UNDO.
define variable v-chk-num as integer.
DEFINE VARIABLE g#report-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-file-name-rep-htm AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-fill-path-RepView AS CHARACTER NO-UNDO.
define variable p-operator as char no-undo.

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, input p-accur as character) forward.



/* **********************  Internal Procedures  *********************** */

PROCEDURE proc-create-HTML:
/*************************/
 define parameter buffer buf_tt for tt-ref.
 
  str4 = replace(str4, chr(10), " "). /* Очищаем текст от служ. символов "Новая линия", пока просмотровщик RepView - не умеет передавать его в Excel */
    str4 = replace(str4, chr(13), " "). /* Очищаем текст от служ. символов "Перевод каретки". */
    str4 = replace(str4, chr(9), " "). /* Очищаем текст от служ. символов "Табуляция" */
    
    str4 =  left-trim(str4, "Выбор объекта:" ).
    if length(str4) > 115 then
    do:
        v-choice-obj = substring(str4, 1, 115) + "...".
    end.
    else
    do:
        v-choice-obj = str4.
    end.


str1 = (if X-TOG-Shift then "С " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + ", смена № "  + string(X-Shift-Start) +
                                " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999"))) + ", смена № " + string(X-Shift-End)
                           else
                                "период с " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999")))
                                   ).

 FOR EACH buf_tt where buf_tt.tot-r-b = 0 and  buf_tt.obj-code = 0 NO-LOCK BY buf_tt.oss-name :
     p-operator = p-operator + " " + buf_tt.oss-name.
     
    end.
     

   

do:
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' /*no-convert*/.
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
                '  </head>' skip.
                
         end.
         do:       
                
                put stream OutStr-html unformatted
                 ' <body>' skip
         '   <table name="Лист1" outline_below="false">' skip
                       '     <thead>' skip
         '       <tr class="set_columns">' skip                          
         '         <td style="width: 100px; border: none;"></td>' skip    /*Объект*/
         '         <td style="width: 150px; border: none;"></td>' skip      /*Оператор*/
         '         <td style="width: 100px; border: none;"></td>' skip    /* Количество чеков*/
         '         <td style="width: 100px; border: none;"></td>' skip   /*Сумма*/
                
                
                   '       </tr>' skip
         .
         
         end.
         do:
         
                    put stream OutStr-html unformatted
            '       <tr>' skip
            '         <td colspan="4" style="border: none; text-align: center; height: 11px; font-size: 11pt; font-weight: bold"> Отчет по переводу средств ОСС   </td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
            
            
              '       <tr>' skip
            '         <td colspan="4" style="border: none; text-align: center; height: 11px; font-size: 11pt; font-weight: bold">' +  str1 + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
            
              '       <tr>' skip
            '         <td style="border: none; text-align: left; height: 11px; font-size: 11pt; font-weight: bold">Объекты: </td>' skip
            '         <td colspan="3" style="border: none"> ' + v-choice-obj +  '</td>' skip
            
            '</tr>' skip
            
            
                        '       <tr>' skip
            '         <td style="border: none; text-align: left; height: 11px; font-size: 11pt; font-weight: bold">Операторы: </td>' skip
            '         <td colspan="3" style="border: none"> '+ p-operator + '</td>' skip
           
            '</tr>' skip
            
               '       <tr>' skip
            '         <td colspan="4" style="border: none; text-align: left; height: 11px; font-size: 11pt; font-weight: bold">  </td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
            .
            end.
            
           
            
                  do:  /* Шапка таблицы отчёта (видимой, как таблица) */
            put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr>' skip
                           ' <th style="text-align: center;">Объект</th>' skip
                            '<th style="text-align: center;">Оператор</th>'skip         
                           ' <th style="text-align: center;">Количество чеков</th>'skip
                            '<th style="text-align: center;">Сумма</th>' skip
                       ' </tr>' skip
       
        .
        end.
        do:
            
    output stream OutStr-html close.

    /* Заполнение линий таблицы "*/
  
    IF v-classified = 1 THEN DO:
         OUTPUT STREAM OutStr-html TO VALUE(v-file-name-rep-htm) APPEND CONVERT TARGET 'UTF-8'.
        FOR EACH buf_tt where buf_tt.tot-r-b = 0 NO-LOCK BY buf_tt.oss-name BY buf_tt.obj-name:
          
            PUT STREAM OutStr-html UNFORMATTED
    
                  ' <tr level="1"> ' skip
                      ' <td style="display: yes; text-align:  left; font-weight: bold">' + buf_tt.obj-name + '</td>' skip
                      ' <td style="display: yes; text-align:  left; font-weight: bold">'  + buf_tt.oss-name + '</td>' skip
                    '         <td style="display: yes; text-align:  left; font-weight: bold">'   + if buf_tt.chk-num <> ? then fnc-convert-dot-to-colon( buf_tt.chk-num, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  left; font-weight: bold">'   + if  buf_tt.chk-sum <> ? then fnc-convert-dot-to-colon(  buf_tt.chk-sum, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    ' </tr>' skip.
                
     
          
        END.
      
         FOR EACH buf_tt where buf_tt.tot-r-b <> 0 NO-LOCK BY buf_tt.oss-name BY buf_tt.obj-name:
               PUT STREAM OutStr-html UNFORMATTED
         ' <tr level="2"> ' skip
         
                      ' <td style="display: yes; text-align:left">'  + buf_tt.obj-name + '</td>' skip
                      ' <td style="display: yes; text-align:right ">' + if buf_tt.tot-r-b <> ? then fnc-convert-dot-to-colon( buf_tt.tot-r-b, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:left ">'   + if buf_tt.chk-num <> ? then fnc-convert-dot-to-colon( buf_tt.chk-num, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:left ">'   + if  buf_tt.chk-sum <> ? then fnc-convert-dot-to-colon(  buf_tt.chk-sum, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    ' </tr>' skip.
       
        end.
    END.
    ELSE IF v-classified = 2 THEN DO:
         OUTPUT STREAM OutStr-html TO VALUE(v-file-name-rep-htm) APPEND CONVERT TARGET 'UTF-8'.
        FOR EACH buf_tt where buf_tt.tot-r-b = 0 NO-LOCK BY buf_tt.obj-name BY buf_tt.oss-name:
           
            PUT STREAM OutStr-html UNFORMATTED
    
                  ' <tr level="1"> ' skip
                      ' <td style="display: yes; text-align:  left; font-weight: bold">'  + buf_tt.obj-name + '</td>' skip
                      ' <td style="display: yes; text-align:  left; font-weight: bold">'  + buf_tt.oss-name + '</td>' skip
                    '         <td style="display: yes; text-align:  left; font-weight: bold">'   + if buf_tt.chk-num <> ? then fnc-convert-dot-to-colon( buf_tt.chk-num, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  left; font-weight: bold">'   + if  buf_tt.chk-sum <> ? then fnc-convert-dot-to-colon(  buf_tt.chk-sum, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    ' </tr>' skip.
                
     
          
        END.
         
        FOR EACH buf_tt where buf_tt.tot-r-b <> 0 NO-LOCK BY buf_tt.oss-name BY buf_tt.obj-name:
                PUT STREAM OutStr-html UNFORMATTED
         '<tr level="2"> 'skip
                            ' <td style="display: yes; text-align:  left">'  + buf_tt.obj-name + '</td>' skip
                      ' <td style="display: yes; text-align:  right">' + if buf_tt.tot-r-b <> ? then fnc-convert-dot-to-colon( buf_tt.tot-r-b, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  left">'   + if buf_tt.chk-num <> ? then fnc-convert-dot-to-colon( buf_tt.chk-num, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  left">'   + if  buf_tt.chk-sum <> ? then fnc-convert-dot-to-colon(  buf_tt.chk-sum, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    ' </tr>' skip.
       
        end.
    END.

    /* Заполнение подвала таблицы */
 /*no-convert*/.
 
        PUT STREAM OutStr-html UNFORMATTED
                    '</table>
            </body>
        </html>'
        .
        /* '" */
    OUTPUT STREAM OutStr-html CLOSE.
end.
END PROCEDURE.

DO: /* S */

    DO: /* Нач_Иниц */
        /* Начальная инициализация таблицы */

        FOR EACH tt-ref EXCLUSIVE-LOCK:
            DELETE tt-ref.
        END.
    
        RUN get-report-num IN parParentProc (
            OUTPUT g#report-num
        ).

        v-file-name-rep-htm = SESSION:TEMP-DIRECTORY + {&DF_Name} + STRING(g#report-num) + ".html".

        OUTPUT TO VALUE(v-file-name-rep-htm).
        OUTPUT CLOSE.

        IF SEARCH("exe\ReportViewer\reportviewer.exe") <> ? THEN
            DO:
                v-fill-path-RepView = SEARCH("exe\ReportViewer\reportviewer.exe").
            END.
        ELSE
            DO:
                MESSAGE "Не найдена программа просмотра отчёта!" VIEW-AS ALERT-BOX ERROR.
            END.


    END. /* Нач_Иниц */
    DO: /* Тело отчёта */

        FOR EACH obj-list NO-LOCK:

          run rep/rpychk0.p ( input "r-shftc2"
                    ,input obj-list.obj-type
                    ,input obj-list.obj-code
                    ,input ? /*p-date-from*/
                    ,input ? /*p-date-to*/
                    ,input X-date-start /*p-shift-date-from*/
                    ,input X-date-end /*p-shift-date-to*/
                    ,input 1 /*p-shift-num-start*/
                    ,input 99 /*p-shift-num-end*/
                    ,input ? /*p-inkas-code*/
                    ) no-error.

		    FOR EACH buf_goods-attr WHERE buf_goods-attr.attr-value = 'oss-pay' 
                                      AND buf_goods-attr.attr-code = {&attr-office-type} No-LOCK,
		        EACH buf_bar-code WHERE buf_bar-code.gds-code = buf_goods-attr.gds-code NO-LOCK:
            
            	    FOR EACH buf_chk-gds-pay WHERE buf_chk-gds-pay.obj-type = obj-list.obj-type
                        		               AND buf_chk-gds-pay.obj-code = obj-list.obj-code
                                               AND ((x-TOG-Shift = YES 
                                                   AND buf_chk-gds-pay.shift-num >= x-Shift-Start
                                                   AND buf_chk-gds-pay.shift-num >= x-Shift-End
                                                   AND buf_chk-gds-pay.shift-date >= x-Date-Start
                                                   AND buf_chk-gds-pay.shift-date <= x-Date-End) 
                                                   OR (x-TOG-Shift = NO 
                                                   AND buf_chk-gds-pay.chk-date >= x-Date-Start
                                                   AND buf_chk-gds-pay.chk-date <= x-Date-End))
                                               AND buf_chk-gds-pay.b-code = buf_bar-code.b-code NO-LOCK:
                        
                        /*определяем оператора*/
                        FIND FIRST buf_chk-gds-attr WHERE buf_chk-gds-attr.doc-code = buf_chk-gds-pay.doc-code
                                                      AND buf_chk-gds-attr.line-num = buf_chk-gds-pay.line-num
                                                      AND buf_chk-gds-attr.attr-code = 'oss-code' NO-LOCK NO-ERROR.
                        IF AVAILABLE buf_chk-gds-attr THEN DO:
                            v-oss-name = string(int(buf_chk-gds-attr.attr-value)) no-error.
                            FIND FIRST ext-classif WHERE ext-classif.classif-subject = {&extclass_oss-ref}
                                                     AND ext-classif.Key#_One = int(v-oss-name) NO-LOCK NO-ERROR.
                            IF AVAILABLE ext-classif THEN DO:
                                v-oss-name = ENTRY(1, ext-classif.charkey_two,{&delim-par}).
                            END.
                            ELSE DO:
                                v-oss-name = 'Нет информации'.
                            END.
                        END.
                        ELSE DO:
                            ASSIGN
                                v-oss-name = 'Не определено'.
                        END.
                        
                        /*учитываем только выбранных операторов*/
                        IF v-operator = '0' OR (LOOKUP(STRING(v-oss-name), v-operator) > 0) THEN DO:
                            IF v-classified = 2 THEN DO: /*итоговая строка по объектам*/
                                FIND FIRST tt-ref WHERE tt-ref.obj-code = obj-list.obj-code and
                                tt-ref.obj-type = obj-list.obj-type 
                                                    AND tt-ref.oss-name = '-' EXCLUSIVE-LOCK NO-ERROR.
				                IF NOT AVAILABLE tt-ref THEN DO:
					                CREATE tt-ref.
					                ASSIGN 
					                tt-ref.obj-code = obj-list.obj-code
					                tt-ref.obj-type = obj-list.obj-type
						                tt-ref.obj-name = obj-list.obj-name
                                        tt-ref.oss-name = '-'
                                        tt-ref.chk-num  = 0
                                        tt-ref.chk-sum  = 0
                                        .
				                END.
                                ASSIGN
                                    tt-ref.chk-num = tt-ref.chk-num + 1
                                    tt-ref.chk-sum = tt-ref.chk-sum + buf_chk-gds-pay.tot-r-b.
                            END.
                            ELSE IF v-classified = 1 THEN DO: /*итоговая строка по операторам*/
                                FIND FIRST tt-ref WHERE tt-ref.obj-type = "" and tt-ref.obj-code = 0 
                                                    AND tt-ref.oss-name = v-oss-name EXCLUSIVE-LOCK NO-ERROR.
				                IF NOT AVAILABLE tt-ref THEN DO:
					                CREATE tt-ref.
					                ASSIGN 
					                tt-ref.obj-type = ""
					                tt-ref.obj-code = 0
						                tt-ref.obj-name = '-'
                                        tt-ref.oss-name = v-oss-name
                                        tt-ref.chk-num  = 0
                                        tt-ref.chk-sum  = 0
                                        .
				                END.
                                ASSIGN
                                    tt-ref.chk-num = tt-ref.chk-num + 1
                                    tt-ref.chk-sum = tt-ref.chk-sum + buf_chk-gds-pay.tot-r-b.
                            END.
                            /*считаем по оператору и объекту*/
		    		        FIND FIRST tt-ref WHERE tt-ref.obj-code = obj-list.obj-code
		    		        and tt-ref.obj-type = obj-list.obj-type
                                                AND tt-ref.oss-name = v-oss-name EXCLUSIVE-LOCK NO-ERROR.
				            IF NOT AVAILABLE tt-ref THEN DO:
    					        CREATE tt-ref.
	    				        ASSIGN 
	    				          tt-ref.obj-code = obj-list.obj-code
                                    tt-ref.obj-type = obj-list.obj-type
		    				        tt-ref.obj-name = obj-list.obj-name
                                    tt-ref.oss-name = v-oss-name
                                    tt-ref.chk-num  = 0
                                    tt-ref.chk-sum  = 0
                                    .
    				        END.
                            ASSIGN
                                tt-ref.chk-num = tt-ref.chk-num + 1
                              tt-ref.chk-sum = tt-ref.chk-sum + buf_chk-gds-pay.tot-r-b.
                                
                                
                      find first tt-ref where tt-ref.obj-code = obj-list.obj-code and
                      tt-ref.obj-type = obj-list.obj-type and
                      tt-ref.tot-r-b = buf_chk-gds-pay.tot-r-b
                      and tt-ref.oss-name  = v-oss-name
                       NO-ERROR.
                               
                                IF NOT AVAILABLE tt-ref THEN DO:
                                CREATE tt-ref.
                                 ASSIGN 
                              
                                 tt-ref.obj-code = obj-list.obj-code
                                    tt-ref.obj-type = obj-list.obj-type
                                    tt-ref.obj-name = obj-list.obj-name
                                    tt-ref.oss-name = v-oss-name
                                    tt-ref.tot-r-b =  buf_chk-gds-pay.tot-r-b.
                             
                                
                                 end.
                                  ASSIGN
                                tt-ref.chk-num = tt-ref.chk-num + 1
                              tt-ref.chk-sum = tt-ref.chk-sum + buf_chk-gds-pay.tot-r-b.
                              
                        END. /*IF AVAILABLE buf_chk-gds-attr */ 
                    END. /*FOR EACH buf_chk-doc*/
                END. /*FOR EACH buf_goods-attr*/
            /*END. /*FOR EACH buf_shift-obj NO-LOCK*/*/
         
        END. /*FOR EACH obj-list NO-LOCK:*/
    END. /* Тело отчёта */

    FIND FIRST tt-ref NO-LOCK NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
            MESSAGE "Для установленных параметров отчета" SKIP "- данные отсутствуют!" VIEW-AS ALERT-BOX WARNING.
    END.
    ELSE DO:
        RUN proc-create-HTML (BUFFER tt-ref).

        IF SEARCH(v-file-name-rep-htm) = ? THEN DO:
            MESSAGE "Не найден файл отчёта: " v-file-name-rep-htm VIEW-AS ALERT-BOX ERROR.
        END.
        ELSE DO:
            v-file-name-rep-htm = SEARCH(v-file-name-rep-htm).
        END.
        os-command no-wait value(v-fill-path-RepView + " true " + v-file-name-rep-htm).
    END.

END.



function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date):
/* Преобразование даты в формат: "01.01.2014" */

    define variable result as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

        return p-str-date.

end function.

function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character):
/* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - точность) */

    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
/*message "dbg-p-data = " p-data skip "p-accur = " p-accur view-as alert-box.*/
    p-data = round(p-data, 2). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).

    return v-str-result.

end function.