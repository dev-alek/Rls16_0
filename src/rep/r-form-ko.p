block-level on error undo, throw.

/*

$Revision: a8e2cf75ddf6, 2506, rls $
$Author: EShklyar $
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: r-form-ko.p $
$Archive: rep/r-form-ko.p $

Форма КО-3

Автор: Shalanin Sergey
Дата создания: 11/10/15
Author: Shalanin Sergey
Creation date: 11/10/15
*/





define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-form-ko.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-form-ko.p $":U .
define variable vss-description as character no-undo init "Форма КО-3".
{ cmp/vssrevis.i }


define input parameter parParentProc   as widget-handle no-undo.


define        variable v-report-name            as character no-undo.         /* Наименование отчёта */
define        variable v-period                 as character no-undo.              /* Период за который формируется отчёт */
define        variable v-short-obj-list         as character no-undo.      /* Перечень выбранных объектов "в одну строку" */
define        variable v-choice-gds             as character no-undo. /* Список выбранных товаров. Вывод - в шапке отчёта */
define        variable v-choice-obj             as character no-undo. /* Выбранный пользователем параметр "Выбор объекта" (в окне параметров). Вывод в шапке отчёта */
define        variable v-full-path-RepView      as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define        variable v-file-name-rep-htm      as character no-undo.   /* Полный путь к файлу отчёта */
define        variable v-par-type               as character no-undo.

define variable v-file-name     as character no-undo .
define variable v-file-name-ind as integer   no-undo .
define variable v-line          as character no-undo .

  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get }
define variable v-cntxt-obj-name      as character no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define variable ex-v-code as char.
define variable in-v-code as char.
define variable v-file-name-rep-htm-2 as character no-undo.
define        variable CurrGrpName              as character no-undo .
define variable p-doc-code as char.
define        variable v-host-code              as integer   no-undo.
define        variable v-curr-code              as integer   no-undo.
define        variable g#report-num             as integer   no-undo .
define variable p#report-num             as integer   no-undo .
define stream  macr_excel .
define stream  out-stream .
define stream OutStr-html.
define variable v-fin-doc-shift-date as date no-undo .
define variable v-fin-doc-shift-num as integer no-undo .
define variable v-fin-doc-shift-date-char as character no-undo .
define variable v-fin-doc-shift-num-char as character no-undo.
define variable v-fin-doc-shift-name as character no-undo .
define variable v-obj-list-code as integer.
define variable v-obj-list-type as char.
define variable v-file as char.

define temp-table tt-fin-doc like fin-doc.
define buffer buf_income for tt-fin-doc.
define buffer buf_expense for tt-fin-doc.


 { cmp/str-glbl.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i new }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ rep/r-sale.i   }
{ trg/factord.i  }
{ ref/fd-attr.i }



/* ************************  Function Implementations ***************** */
function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, input p-accur as character) forward.
/* ***************************  Main Block  *************************** */




run get-full-path-RepViewer(output v-full-path-RepView).   
  
run get-report-num in parParentProc(output g#report-num).

run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).

run create-file(v-file-name-rep-htm). 

v-report-name = "Журнал регистрации ПКО и РКО (КО-3)".

/*run proc-create-HTML (input v-file-name-rep-htm*/
/*,input v-cntxt-host-name-obj                   */
/*    ,input v-report-name                       */
/*    ,input p-doc-code                          */
/*    ,input p-doc-date                          */
/*    ,input p-object                            */
/*    ,input v-izl-sum                           */
/*    ,input v-izl-qnty                          */
/*    ,input v-ned-sum                           */
/*    ,input v-ned-qnty                          */
/*                                               */
/*    ).                                         */
for each obj-list:
    
 { gbl/hostname.i obj-list.obj-type obj-list.obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
v-obj-list-code = obj-list.obj-code.
v-obj-list-type = obj-list.obj-type.
end.


if x-TOG-Shift = no then 
do:


    for each fin-doc where fin-doc.doc-date  >= X-date-Start and fin-doc.doc-date <= X-date-End and fin-doc.obj-code = v-obj-list-code and fin-doc.obj-type = v-obj-list-type and (fin-doc.fin-doc-type = {&expense-cash} or fin-doc.fin-doc-type = {&income-cash}) :
    
        find first tt-fin-doc where 
            tt-fin-doc.obj-type = fin-doc.obj-type and
            tt-fin-doc.obj-code = fin-doc.obj-code and 
            tt-fin-doc.fin-doc-code   = fin-doc.fin-doc-code no-error.
        
        if not available tt-fin-doc then 
        do:
            create tt-fin-doc.
            buffer-copy fin-doc to tt-fin-doc.
   
        end.
    end.
end.

else 
do:
       
    find last  shift-obj where shift-obj.obj-code = v-obj-list-code and   shift-obj.obj-type = v-obj-list-type  and shift-obj.shift-date = x-Date-Start and shift-obj.shift-num   >= x-Shift-Start no-lock no-error .
    if shift-obj.close-date = ?  then shift-obj.close-date = today.
    for each fin-doc where fin-doc.doc-date  >= shift-obj.shift-date and fin-doc.obj-code = v-obj-list-code and fin-doc.obj-type = v-obj-list-type and (fin-doc.fin-doc-type = {&expense-cash} or fin-doc.fin-doc-type = {&income-cash}) :
               
       
        /*                                                  
        run fin-doc-attr-value in this-procedure (
            input fin-doc.host-code
            ,input fin-doc.fin-doc-code
            ,input fin-doc.shift-date}
            ,output v-fin-doc-shift-date-char
            ) no-error.
        run fin-doc-attr-value in this-procedure (
            input fin-doc.host-code
            ,input fin-doc.fin-doc-code
            ,input {&fd-attr-shift-num}
            ,output v-fin-doc-shift-num-char
            ) no-error.
            */
        if (fin-doc.shift-date > X-date-Start   or (fin-doc.shift-date = X-date-Start and fin-doc.shift-num >= x-Shift-Start)) and
            (fin-doc.shift-date < X-date-End or (fin-doc.shift-date = X-date-End and fin-doc.shift-num <= x-Shift-End))
            then
        do:
                     
            find first tt-fin-doc where 
                tt-fin-doc.obj-type = fin-doc.obj-type and
                tt-fin-doc.obj-code = fin-doc.obj-code and 
                tt-fin-doc.fin-doc-code   = fin-doc.fin-doc-code no-error.
        
            if not available tt-fin-doc then 
            do:
                create tt-fin-doc.
                buffer-copy fin-doc to tt-fin-doc.
   
            end.
        end. 
    end.
end.
do:


    output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
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
    end. 
    
    
do:
    put stream OutStr-html unformatted

        '     <body>' skip
        '  <A NAME="тит"><H1><EM></EM></H1></A>' skip
        '<TABLE name="тит"  fit_to_page="true" orientation="landscape" CELLSPACING="0" COLS="16" BORDER="0">'skip
        '  <COLGROUP SPAN="10" WIDTH="66">'skip
        ' <COLGROUP WIDTH="30">'skip
        '<COLGROUP WIDTH="110">'skip
        '<COLGROUP SPAN="3" WIDTH="66">'skip
        '<COLGROUP WIDTH="133"></COLGROUP>' skip

  

        '<TR>'skip
        '<TD  style="width: 6px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 79px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 11px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 42px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 56px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 89px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 15px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 63px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 49px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 53px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 9px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 50px; text-align: left;border: none"></TD>'skip
        '<TD style="width: 50px; text-align: left;border: none"></TD>'skip
        '<TD colspan="3" style="text-align: left;border: none"> Унифицированная форма № КО-3</TD>'skip
           
        '</TR>'skip

        '<TR>'skip
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD colspan="3"style="text-align: left;border: none">Утверждена постановлением Госкомстата</TD>'skip
           
        '</TR>'skip
    
        '<TR>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD colspan = "3" style="text-align: left;border: none"> России от 18.08.98 г. № 88 </TD>'skip
   
        '</TR>'skip
            
            
        '<TR>'skip
        '<TD HEIGHT="18" style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="width: 42px; text-align: left;border: none"></TD>'skip
        '<TD  style="width: 105px; text-align: left;border: none"></TD>'skip
        '<TD STYLE="width: 127px; border:  1px solid black; text-align: center ;">Код</TD>'skip
        '</TR>'skip
            
        '<TR>'skip
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none">Форма по ОКУД</TD>'skip
        '<TD STYLE="border: 1px solid black;text-align: center;">0310003</TD>'skip
        '</TR>'skip
            
        '<TR>'skip
        '<TD COLSPAN="7"  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black;  text-align: center"> ' + v-cntxt-host-name-obj + '  </TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none">по ОКПО</TD>'skip
        '<TD STYLE="border: 1px solid black;text-align: left;">  </TD>'skip
        '</TR>'skip
            
        '<TR>'skip
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left; border: none"></TD>'skip
          '<TD colspan="3" style="text-align: center; border: none"> (организация) </TD>'skip
           
        '<TD style="text-align: left; border: none"></TD>'skip
        '<TD style="text-align: left; border: none"></TD>'skip
        '<TD style="text-align: left; border: none"></TD>'skip
        '<TD style="text-align: left; border: none"></TD>'skip
        '<TD style="text-align: left; border: none"></TD>'skip
        '<TD style="text-align: left; border: none"></TD>'skip
        '<TD style="text-align: left; border: none"></TD>'skip
        '<TD style="text-align: left; border: none"></TD>'skip
        '<TD style="text-align: left; border: none"></TD>'skip
        '<TD style="text-align: left; border: none"></TD>'skip
        '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
        '</TR>'skip
            
        '<TR>'skip
    
        '<TD  COLSPAN="7" HEIGHT="17"  STYLE="border: none; border-bottom: 1px solid black;   text-align: center"> ' + v-obj-list-type + " " + string(v-obj-list-code)+  '</TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
        '</TR>'skip
            
            .
            end.
    
do:  /* Титульный лист отчета */
    put stream OutStr-html unformatted
            
        '<TR>'skip
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
/*        '<TD style="text-align: left;border: none "></TD>'skip*/
          '<TD colspan="5" style="text-align: center;border: none">(структурное подразделение)</TD>'skip
/*        '<TD style="text-align: left;border: none"></TD>'skip*/
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD STYLE="border: 1px solid black;text-align: left"></TD>'skip
        '</TR>'skip
            
            
        '<TR>'skip
    
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD STYLE="border: 1px solid black;text-align: left"></TD>'skip
        '</TR>'skip
    
            
            
        '<TR>'skip
            
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '</TR>'skip
            
        '<TR>'skip
            
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '</TR>'skip
        '<TR>'skip
            
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '</TR>'skip
        
        '<TR>'skip
            
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '</TR>'skip
        '<TR>'skip
            
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '</TR>'skip
            
        .
        
end.
    
do:  /* Титульный лист отчета */
    put stream OutStr-html unformatted
        '<TR>'skip
   
        '<TD colspan = "16" style="font-weight: bold; text-align: center; border: none">ЖУРНАЛ  РЕГИСТРАЦИИ</TD>'skip
     
        '</TR>'skip
            
            
            
        '<TR>'skip
        '<TD colspan = "16" style="font-weight: bold; text-align: center; border: none">ПРИХОДНЫХ И РАСХОДНЫХ КАССОВЫХ ДОКУМЕНТОВ</TD>'skip
        '</TR>'skip
             
        '<TR>'skip 
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
                '<TD style="text-align: left;border: none"></TD>'skip
        
                '<TD style="text-align: left;border: none"></TD>'skip
        
        '<TD colspan = "2" STYLE="border: none; border-bottom: 1px solid black"></TD>'skip
        '<TD style="text-align: left;border: none">Г.</TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
            
        '</TR>'skip
        
   
                       '<TR style="height: 50pt;">'skip 
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
            
        '</TR>'skip
             
            
        '<TR>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD colspan="3" style="border: none; text-align: center; border-bottom: 1px solid black"> </TD>'skip
   
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
                '<TD style="text-align: left;border: none"></TD>'skip
        
                '<TD style="text-align: left;border: none"></TD>'skip
        
        '<TD COLSPAN="4" STYLE="border: none; border-bottom: 1px solid black;  text-align: center"></TD>'skip

        '<TD style="text-align: left;border: none"></TD>'skip
        '</TR>'skip
            
        '<TR>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD colspan= "3" style="text-align: center;border: none">(должность)</TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
                '<TD style="text-align: left;border: none"></TD>'skip
        
                '<TD style="text-align: left;border: none"></TD>'skip
        
        '<TD colspan= "4" style="text-align: center;border: none">(фамилия, имя, отчество)</TD>'skip         
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
       
        '</TR>'skip
        .
end.
do: 
    put stream OutStr-html unformatted
        '</tbody>'
        '   </table>' skip
        '  </body>' skip
        '</html>' skip.
end.
          
        



run define-full-path-Report-2(input g#report-num, output v-file-name-rep-htm-2).

run create-file(v-file-name-rep-htm-2). 

v-report-name = "Журнал регистрации ПКО и РКО (КО-3) (страница 2 )".

do:


    output stream macr_excel to value(v-file-name-rep-htm-2) append convert target 'UTF-8'.
            put stream macr_excel unformatted
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
    end. 

 do:  /* Параметры "глобальной" таблицы отчёта */
     put stream macr_excel unformatted
         ' <body>' skip
         '   <table name="КО-3" fit_to_page="true"  orientation="Portrait">' skip
     '     <thead>' skip
     '       <tr class="set_columns">' skip                          
     '         <td style="width:80px; border: none;"></td>' skip 
     '         <td style="width:80px; border: none;"></td>' skip 
     '         <td style="width:80px; border: none;"></td>' skip 
     '         <td style="width:220px; border: none;"></td>' skip 
     '         <td style="width:80px; border: none;"></td>' skip 
     '         <td style="width:80px; border: none;"></td>' skip 
     '         <td style="width:80px; border: none;"></td>' skip 
     '         <td style="width:220px; border: none;"></td>' skip                                      
         '       </tr>' skip
          .
             
            end.


 do:  /* Шапка таблицы отчёта (видимой, как таблица) */
            put stream macr_excel unformatted
            '     <tbody>' skip
            '       <tr style="height: 50pt;">' skip
            '         <th  colspan="2" style="background-color:#ffffcc; font-size:11pt; text-align: center;">Приходный документ</th>' skip
            '         <th   rowspan = "2" style="background-color:#ffffcc; font-size:11pt; text-align: center;">Сумма, руб. коп</th>' skip
            '         <th  rowspan = "2" style="background-color:#ffffcc; font-size:11pt;text-align: center;">Примечание</th>' skip
            '         <th  colspan="2" style="background-color:#ffffcc; font-size:11pt; text-align: center;">Расходный документ</th>' skip
            '         <th   rowspan = "2" style="background-color:#ffffcc;font-size:11pt; text-align: center;">Сумма, руб. коп.</th>' skip
            '         <th  rowspan = "2" style="background-color:#ffffcc;  font-size:11pt; text-align: center;">Примечание</th>' skip       
            '</tr >'   skip  
            
            '       <tr style="height: 30pt;">' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">Дата</th>' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">Номер</th>' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">Дата</th>' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">Номер</th>' skip
            '</tr>'
         
         
            '       <tr style="height: 40pt;">' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">1</th>' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">2</th>' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">3</th>' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">4</th>' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">5</th>' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">6</th>' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">7</th>' skip
            '       <th   style="background-color:#ffffcc; font-size:11pt;text-align: center;">8</th>' skip
            '</tr>'
         
.
end.

do:
  
 

    find first buf_income where buf_income.obj-code  = v-obj-list-code and buf_income.obj-type = v-obj-list-type and buf_income.fin-ext-doc-type = {&income-cash}    no-lock no-error.                                                                                                                                                                      
    find first buf_expense where buf_expense.obj-code  = v-obj-list-code and buf_expense.obj-type = v-obj-list-type and buf_expense.fin-ext-doc-type =  {&expense-cash}  no-lock  no-error .
                                                                                                                                                                                   


    do while available buf_income or available buf_expense  : 
        do:
          
            put stream macr_excel unformatted
                '<tr>' skip
                '         <td  style="display: yes; font-size:11pt; text-align: left">' + (if available buf_income    then    fnc-DD-MM-YYYY(date(string(buf_income.doc-date,"99/99/9999"))) else " ")  + '</td>' skip
                '         <td style="display: yes; font-size:11pt; text-align:  left">' + (if available buf_income   then buf_income.prn-doc-code else " ") +  '</td>' skip
                '         <td style="display: yes; font-size:11pt; text-align:  left">' + (if available buf_income   then fnc-convert-dot-to-colon( buf_income.sum-doc, "->>>>>>>9.99") else " ") + '</td>' skip
                '         <td style="display: yes; font-size:11pt; word-wrap: break-word; text-align:  left">' + (if available buf_income   then   buf_income.receiver-name else " ") + '</td>' skip
                '         <td  style="display: yes; font-size:11pt; text-align: left">' + (if available buf_expense  then  fnc-DD-MM-YYYY(date(string(buf_expense.doc-date,"99/99/9999"))) else " ") + '</td>' skip
                '         <td style="display: yes; font-size:11pt; text-align:  left">' + (if available buf_expense then buf_expense.prn-doc-code else " ") +  '</td>' skip
                '         <td style="display: yes; font-size:11pt; text-align:  left">' + (if available buf_expense then  fnc-convert-dot-to-colon( buf_expense.sum-doc, "->>>>>>>9.99") else " ")  + '</td>' skip
                '         <td style="display: yes; font-size:11pt; word-wrap: break-word; text-align:  left">' + (if available buf_expense   then   buf_expense.receiver-name else " ") + '</td>' skip
                '</tr>' skip
                .    
               
            find next   buf_income   where buf_income.obj-code  = v-obj-list-code and buf_income.obj-type = v-obj-list-type and buf_income.fin-ext-doc-type = {&income-cash} no-lock  no-error .
            find next  buf_expense   where buf_expense.obj-code  = v-obj-list-code and buf_expense.obj-type = v-obj-list-type and buf_expense.fin-ext-doc-type =  {&expense-cash} no-lock no-error .              
        end.
    end.  
end.


do: 
    put stream macr_excel unformatted
        '</tbody>'skip
        '</table>' skip
        '</body>' skip
        '</html>' skip.
                output stream OutStr-html close.
        
end.


  run search-full-path-Report(input v-file-name-rep-htm).

run search-full-path-Report(input v-file-name-rep-htm-2).

run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm-2 , input v-file-name-rep-htm).     


            
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


procedure define-full-path-Report:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
    /* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory  + string(p-rep-num)  + ".html".

end procedure.


procedure Report-Viewer:            /* Запуск на выполнение RV (input Полный_путь_имя_файла_RV, input Полный_путь_имя_файла_отчHTML) */
/* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.
define input parameter p-file-name-rep-htm-2 as char.
    os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm-2) + " " + search(p-file-name-rep-htm)).

end procedure.
            
procedure define-full-path-Report-2:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
    /* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory  + string(p-rep-num) +  "страница-2"+ ".html".

end procedure.




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
