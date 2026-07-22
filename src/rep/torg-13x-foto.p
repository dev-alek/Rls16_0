block-level on error undo, throw.
/*

$Revision: a8e2cf75ddf6, 2506, rls $
$Author: EShklyar $
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: torg-13x-foto.p $
$Archive: rep/torg-13x-foto.p $

Печать формы ТОРГ-13

Автор: Шаланин Сергей 
Дата создания: 09/15/05
Author: Shalanin Sergey
Creation date: 09/15/05

Input:

Output:

*/


define input parameter  parparentproc     as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter p-print-gold         as logical          no-undo. /* Если yes, то печатается модификация формы для ювелирных изделмй */
define input parameter p-print-prod         as logical          no-undo. /* Если yes, то идет сортировка по производителям */
define input parameter p-break-name         as logical          no-undo. /* Если yes, то названия товаров переносятся */

def var vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: torg-13x-foto.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/torg-13x-foto.p $":U .  
def var vss-description as character no-undo init "Печать формы ТОРГ-13".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/r-pril.i          }
{ str/trdcalib.i        }
{ str/in-vatp.i def     }
{ str/out-vatp.i def    }
{ rep/p-fmt.i           }
{ rep/r-cliprp.i def    }
{ cmp/breakstr.i        }
{ rep/fmtcli.i          }
{ gbl/clntattr.i        }
{ rep/torgconf.i        }
{ ref/gds-attr.i }

def buffer t-doc       for trn-doc.
def buffer OurObject   for clients.
def buffer buf_clients for clients.
def buffer buf_units   for units. 

define stream Out-stream .

def shared var PrintScale as logical no-undo.
def shared var costprice  as logical no-undo.
def shared var sort-name  as logical no-undo.
def shared var sort-gr    as logical no-undo.

def temp-table temp_gds-name no-undo
    field gds-name   like goods.gds-name
    field string-num as integer
    index sn is primary unique string-num
    .
def    var      v-gds-name           like goods.gds-name no-undo.
def    var      v-gds-name-counter   as integer   no-undo.
define variable v-poluch             as char.
define variable v-otprav             as char.

define variable v-dircode2           as character no-undo .
define variable v-tthd               as handle    no-undo.
define variable v-picture            as character no-undo.
define VARIABLE vPar-val             as character no-undo .
define VARIABLE vPar-type            as character no-undo .
define VARIABLE v-ph-dir             as character no-undo .
define variable p-level              as integer.
define variable g-level              as integer.
def    var      tdoc-prt             as logical   no-undo.
def    var      tdoc-code            like trn-doc.doc-code no-undo.
def    var      v-doc-date-string    as character no-undo.
define variable v-param-types        as character no-undo.
define variable v-value-char         as character no-undo.
define variable v-val-date           as date      no-undo.
define variable v-val-decimal        as decimal   no-undo.
define variable v-val-integer        as integer   no-undo.
define variable v-val-logical        as logical   no-undo.
define variable Path-To-Dir-Pictures as character no-undo .
define variable v-value              as character no-undo.
define variable v-type               as character no-undo.
def    var      rootnode_code        as integer   no-undo.

def    var      LineCounter          as integer   no-undo.
def    var      txt-LC               as char      no-undo.
def    var      s1                   as char      no-undo.
def    var      s2                   as char      no-undo.

define variable v-cntxt-obj-name      as character no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define variable v-cntxt-host-code-obj as integer no-undo.

def    var      Node_Code            like gds-prt.upper-code no-undo.

def    var      PriceNoNDS           as decimal   no-undo.
def    var      PricendS             as decimal   no-undo.
def    var      PricewithNDS         as decimal   no-undo.

def    var      tqnty                as decimal   no-undo.
def    var      SumNoNDS             as decimal   no-undo.
def    var      SumNDS               as decimal   no-undo.
def    var      SumwithNDS           as decimal   no-undo.

def    var      sum-tqnty            as decimal   no-undo.
def    var      sum-SumNoNDS         as decimal   no-undo.
def    var      sum-SumNDS           as decimal   no-undo.
def    var      sum-SumwithNDS       as decimal   no-undo.

def    var      prt-tqnty            as decimal   no-undo.
def    var      prt-SumNoNDS         as decimal   no-undo.
def    var      prt-SumNDS           as decimal   no-undo.
def    var      prt-SumwithNDS       as decimal   no-undo.

def    var      sum-prt-tqnty        as decimal   no-undo.
def    var      sum-prt-SumNoNDS     as decimal   no-undo.
def    var      sum-prt-SumNDS       as decimal   no-undo.
def    var      sum-prt-SumwithNDS   as decimal   no-undo.

def    var      Pg-tqnty             as decimal   init 0 no-undo.
def    var      Pg-SumNoNDS          as decimal   no-undo.
def    var      Pg-SumNDS            as decimal   no-undo.
def    var      Pg-SumwithNDS        as decimal   no-undo.
def    var      PrevPage             as integer   init 0 no-undo.

def    var      tot-SumNoNDS         as decimal   no-undo.
def    var      tot-SumNDS           as decimal   no-undo.
def    var      tot-SumwithNDS       as decimal   no-undo.

def    var      PrtName              as char      no-undo.

def    var      OKEI                 as char      no-undo.
def    var      tb-code              as char      no-undo.
def    var      qnty-opl             as decimal   no-undo.
def    var      qnty-pl              as decimal   no-undo.
def    var      mass-b               as decimal   no-undo.
def    var      mass-n               as decimal   no-undo.

def    var      v-line-counter       as integer   no-undo.

def    var      v-not-gold           as logical   no-undo.

def    var      v-new-prod           as logical   no-undo.
def    var      v-prod-type          like doc-line.prod-type no-undo.
def    var      v-prod-code          like doc-line.prod-code no-undo.
def    var      v-prod-name          like clients.obj-name no-undo.

def    var      sym1                 as char      init ":" no-undo.
def    var      sym2                 as char      init ":" no-undo.
def    var      sym3                 as char      init ":" no-undo.
def    var      sym4                 as char      init ":" no-undo.
def    var      sym5                 as char      init ":" no-undo.
def    var      sym6                 as char      init ":" no-undo.
def    var      sym7                 as char      init ":" no-undo.
def    var      sym8                 as char      init ":" no-undo.
def    var      sym9                 as char      init ":" no-undo.
def    var      sym10                as char      init ":" no-undo.

def    var      Line                 as char      no-undo.
def    var      UndLine              as char      no-undo.

def    var      unit-str             as char      no-undo.
def    var      val-str              as char      no-undo.
define variable v-host-code          as integer   no-undo.

define variable g#report-num         as integer   no-undo.
define variable g#quest-print        as logical   no-undo.
define variable g#log                as logical   no-undo.
define variable v-report-name-html   as char.
define variable v-full-path-RepView  as char.
define stream outstr-html.


function fnc-DD-MM-YYYY returns character 
    (input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
    (input p-data as decimal, input p-accur as character) forward.

/*{ gbl/working.i }*/

run get-full-path-RepViewer(output v-full-path-RepView).     
  
run get-report-num in parParentProc(output g#report-num).

run get-quest-print in parparentproc (
    output g#quest-print
    ).

run define-full-path-Report(input g#report-num, output v-report-name-html).

run create-file(v-report-name-html).   




find first t-doc no-lock
    where recid( t-doc ) = rec_id
    .
 { gbl/hostname.i t-doc.obj-type t-doc.obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }



find OurObject where OurObject.obj-type = t-doc.obj-type and
    OurObject.obj-code = t-doc.obj-code no-lock no-error.
case OurObject.obj-type :
    when {&shop}
    then 
        do:
            find shop where shop.obj-code = OurObject.obj-code no-lock .
            tdoc-prt = shop.doc-prt.
        end.
    when {&stock}
    then 
        do:
            find store where store.obj-code = OurObject.obj-code no-lock .
            tdoc-prt = store.doc-prt .
        end.
end case.

if not tdoc-prt then
    PrintScale = no .

    
    
do:


    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8'.
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
              
        '      table ' + chr(123) + ' border-collapse: collapse; font-size:9pt; font-family:Calibri; table-layout: fixed; width: 1157px; hight:  padding: 8px;  ' + chr(125) skip
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
        ' <body>' skip
        '   <table name="Лист1" fit_to_page="true" orientation="landscape" outline_below="false">' skip
        
        '     <thead>' skip
        '       <tr class="set_columns">' skip                 
        '         <td style="width: 100px; border: none;"></td>' skip        
        '         <td style="width: 200px; border: none;"></td>' skip  
        '         <td style="width: 200px; border: none;"></td>' skip    
          
        '         <td style="width: 100px; border: none;"></td>' skip      
        '         <td style="width: 50px; border: none;"></td>' skip   
        '         <td style="width: 100px; border: none;"></td>' skip     
        '         <td style="width: 100px; border: none;"></td>' skip   
        '         <td style="width: 120px; border: none;"></td>' skip 
        
        '         <td style="width: 120px; border: none;"></td>' skip


        '       </tr>' skip
        .
end.
do:
          
          
    put stream OutStr-html unformatted
        

      
        '<TR>'skip
        '<TD HEIGHT="18" style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
    
  
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        
        '<TD  style=" text-align: left;border: none"></TD>'skip
        '<TD  style=" text-align: left;border: none"></TD>'skip
        '<TD STYLE=" border:  1px solid black; text-align: center ;">Код</TD>'skip
        '</TR>'skip
    
        '<TR>'skip
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip  
        '<TD  style="text-align: left;border: none"></TD>'skip     
           
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: right;border: none">Форма по ОКУД</TD>'skip
        '<TD STYLE="border: 1px solid black;text-align: center;">0330213</TD>'skip
        '</TR>'skip
            
        '<TR>'skip
        '<TD COLSPAN="4"  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black;  text-align: center"> ' + v-cntxt-host-name-obj + '  </TD>'skip
     
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip

        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: right;border: none">по ОКПО</TD>'skip
        '<TD STYLE="border: 1px solid black;text-align: left;">  </TD>'skip
        '</TR>'skip
        
        '<TR>'skip
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        
        '<TD   colspan= "2" style="text-align: right;border: none">Вид деятельности по ОКДП </TD>'skip
        '<TD   STYLE="border: 1px solid black; text-align: center;"></TD>'skip
        '</TR>'skip
        
      
/*                                                                         */
/*        '<TR>'skip                                                       */
/*        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip*/
/*        '<TD  style="text-align: left;border: none"></TD>'skip           */
/*        '<TD  style="text-align: left;border: none"></TD>'skip           */
/*        '<TD  style="text-align: left;border: none"></TD>'skip           */
/*        '<TD  style="text-align: left;border: none"></TD>'skip           */
/*                                                                         */
/*        '<TD  style="text-align: left;border: none"></TD>'skip           */
/*        '<TD  style="text-align: left;border: none"></TD>'skip           */
/*        '<TD  style="text-align: left;border: none">по ОКДП</TD>'skip    */
/*        '</TR>'skip                                                      */
/*                                                                         */
        .
end.
        
do:
    put stream OutStr-html unformatted       
        '<TR>'skip
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
            
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: right;border: none">Вид операции</TD>'skip
        '<TD STYLE="border: 1px solid black;text-align: center;">'+ (if t-doc.doc-type = {&income} then " приход"
        else ( if t-doc.doc-type = {&return}    then "возврат"
        else " расход" ))  + '</TD>'
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
        '</TR>'skip
             
        
        '<TR>'skip     
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align:right;border: none; font-weight: bold;">Накладная     </TD>'skip
        '<TD style="text-align: left; border: 1px solid black;font-weight: bold;">' +  string( t-doc.doc-code ) + '</TD>'skip
        '<TD style="text-align: left;border: 1px solid black;font-weight: bold;">' + fnc-DD-MM-YYYY(date(string(t-doc.doc-date,"99/99/9999")))  + '</TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip
                
        '<TD style="text-align: left;border: none"></TD>'skip
        '</TR>'skip
    
    
        '<TR>'skip         
        '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip     
        '<TD colspan = "5" style="text-align: center;border: none; font-weight: bold;">НА ВНУТРЕННЕЕ ПЕРЕМЕЩЕНИЕ, ПЕРЕДАЧУ ТОВАРОВ, ТАРЫ</TD>'skip
                        '<TD style="text-align: left;border: none"></TD>'skip
                
        '<TD style="text-align: left;border: none"></TD>'skip
        '</TR>'skip
    
    
    
    
        '<TR>'skip
        '<TD HEIGHT="17" colspan = "5" style="text-align: left;border: 1px solid black;font-weight: bold;">Отправитель</TD>'skip
        '<TD colspan = "4" style="text-align: left;border: 1px solid black;font-weight: bold;">Получатель</TD>'skip
        '</TR>'skip
        '     </thead>' skip
        .    
              
end.
    
if t-doc.doc-type = {&income} or t-doc.doc-type = {&return}
    then 
do:
    find first clients no-lock
        where clients.obj-type = t-doc.cli-type
        and clients.obj-code = t-doc.cli-code
        .
end.
else 
do:
    find first clients no-lock
        where clients.obj-type = t-doc.obj-type
        and clients.obj-code = t-doc.obj-code
        .
end.
v-otprav = string( clients.obj-name ) .
    
    
if t-doc.doc-type = {&income} or t-doc.doc-type = {&return}
    then 
do:
    find first clients no-lock
        where clients.obj-type = t-doc.obj-type
        and clients.obj-code = t-doc.obj-code
        .
end.
else 
do:
    find first clients no-lock
        where clients.obj-type = t-doc.cli-type
        and clients.obj-code = t-doc.cli-code
        .
end.
 
v-poluch = string( clients.obj-name ).
do:
    
    put stream OutStr-html unformatted  
        '<TR>'skip
            
        '<TD HEIGHT="17" colspan = "5" style="text-align: left;border: 1px solid black;">' +  v-otprav + '</TD>'skip
        
        '<TD colspan = "4" style="text-align: left;border: 1px solid black;">' +  v-poluch + '</TD>'skip
        
        '</TR>'skip
        .
    
    
    output stream OutStr-html close.
end.
    
output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8'.
if costprice = yes then 
do:
          
    do:
        put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr style="height: 60px;">' skip
            '         <th     style="background-color:#ffffcc; text-align: center">Артикул</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Название товара</th>' skip
        
            '         <th  style="background-color:#ffffcc; text-align: center">Фото товара</th>' skip       
              
            '         <th  style="background-color:#ffffcc; text-align: center">Код товара</th>' skip       
            '         <th  style="background-color:#ffffcc; text-align: center">ед. изм.</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Количество</th>' skip
      '         <th  style="background-color:#ffffcc; text-align: center">Учетная цена с НДС</th>' skip
                '         <th  style="background-color:#ffffcc; text-align: center">Сумма в учетных ценах  без НДС</th>' skip
                '         <th  style="background-color:#ffffcc; text-align: center">Сумма в учетных ценах с НДС</th>' skip
            '</tr>' skip
            .
    /*            output stream OutStr-html close.*/
    end.

end.
else 
do:
        
    do:
        put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr style="height: 60px;">' skip
            '         <th     style="background-color:#ffffcc; text-align: center">Артикул</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Название товара</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Фото товара</th>' skip       
          
        
            '         <th  style="background-color:#ffffcc; text-align: center">Код товара</th>' skip       
            '         <th  style="background-color:#ffffcc; text-align: center">ед. изм.</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Количество</th>' skip
       '         <th  style="background-color:#ffffcc; text-align: center">Цена с НДС</th>' skip
                '         <th  style="background-color:#ffffcc; text-align: center">Сумма без НДС</th>' skip
                '         <th  style="background-color:#ffffcc; text-align: center">Сумма с НДС</th>' skip
            '</tr>' skip
            .
    /*                 output stream OutStr-html close.*/
    end.
end.
        
        
        

if p-print-prod = yes
    and sort-gr = yes then 
do:
    p-level = 2.
    g-level = 3.
end.
  
if sort-gr = yes and p-print-prod = no then 
do:   
    g-level = 2.
    p-level = 1.
end.

if sort-name = yes
    then 
do:
    if p-print-prod = yes
        then 
    do:
        if sort-gr = yes
            then 
        do:
            for each doc-line no-lock
                where doc-line.doc-code = t-doc.doc-code
                ,first goods no-lock
                where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
                ,first clients no-lock
                where clients.obj-type   = goods.prod-type
                and clients.obj-code   = goods.prod-code
                break   by clients.obj-name
                by goods.grp-name
                by goods.gds-name
                :
                if first-of (clients.obj-name)
                    then 
                do:
                    run print-prod-line in this-procedure.
                end.
                if first-of (goods.grp-name)
                    then 
                do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = yes */
        else 
        do:
            for each doc-line no-lock
                where doc-line.doc-code = t-doc.doc-code
                , first goods no-lock
                where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
                ,first clients no-lock
                where clients.obj-type   = goods.prod-type
                and clients.obj-code   = goods.prod-code
                break   by clients.obj-name
                by goods.gds-name
                :
                if first-of (clients.obj-name)
                    then 
                do:
                    run print-prod-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = no */
    end.            /* p-print-prod = yes */
    else 
    do:
        if sort-gr = yes
            then 
        do:
            for each doc-line no-lock
                where doc-line.doc-code = t-doc.doc-code
                , first goods no-lock
                where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
                break by goods.grp-name
                by goods.gds-name
                :
                if first-of (goods.grp-name)
                    then 
                do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = yes */
        else 
        do:
            for each doc-line no-lock
                where doc-line.doc-code = t-doc.doc-code
                , first goods no-lock
                where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
                break by goods.gds-name
                :
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = no */
    end.            /* p-print-prod = no */
end.        /* sort-name = yes */
else 
do:
    if p-print-prod = yes
        then 
    do:
        if sort-gr = yes
            then 
        do:
            for each doc-line no-lock
                where doc-line.doc-code = t-doc.doc-code
                , first goods no-lock
                where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
                ,first clients no-lock
                where clients.obj-type   = goods.prod-type
                and clients.obj-code   = goods.prod-code
                break   by clients.obj-name
                by goods.grp-name
                by doc-line.line-num
                :
                if first-of (clients.obj-name)
                    then 
                do:
                    run print-prod-line in this-procedure.
                end.
                if first-of (goods.grp-name)
                    then 
                do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.
        else 
        do:
            for each doc-line no-lock
                where doc-line.doc-code = t-doc.doc-code
                , first goods no-lock
                where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
                , first clients no-lock
                where clients.obj-type   = goods.prod-type
                and clients.obj-code   = goods.prod-code
                break   by clients.obj-name
                by doc-line.line-num
                :
                if first-of (clients.obj-name)
                    then 
                do:
                    run print-prod-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.
    end.        /* p-print-prod = yes */
    else 
    do:
        if sort-gr = yes
            then 
        do:
            for each doc-line no-lock
                where doc-line.doc-code = t-doc.doc-code
                , first goods no-lock
                where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
                break by goods.grp-name
                by doc-line.line-num
                :
                if first-of (goods.grp-name)
                    then 
                do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = yes */
        else 
        do:
            for each doc-line no-lock
                where doc-line.doc-code = t-doc.doc-code
                , first goods no-lock
                where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
                break by doc-line.line-num
                :
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = yes */
    end.        /* p-print-prod = no */
end.        /* sort-name = no */
  
    
    
procedure print-doc-line: 
    /*    do                             */
    /*        on error undo, return error*/
    /*        :                          */



    {gbl/conf-rd.i "'ph-dir':u" "'':u" "'':u" 0 "'':u" "'':u" "'':u" NO vPar-val vPar-type no-error}
     
    if vPar-val = "" then vPar-Val = "C:\temp". 
    else vPar-Val = vPar-Val.
    
    /*смотрим схему хранения изображения (общая или по товарам)*/ 
    run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_shema-foto} /*p-param-code*/
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer /*1 - общая директория; 2 по товарам*/
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
    delete object v-tthd.
      
    /*  vPar-Val = "C:\123".*/
  
    run gds-attr-value in this-procedure (
        input goods.gds-code
        ,input "image-list"
        ,output v-value
        ,output v-type) no-error.
        
    if v-value <> "" then 
    do: /* есть атрибут */
        if v-val-integer = 1 then 
        do:
            Path-To-Dir-Pictures = vPar-val + "\gds\".
        end.
        else 
        do:
            Path-To-Dir-Pictures = vPar-val + "\" + string(goods.gds-code).
        end.  
    end.
    
    if v-value > '' then  
    do:
        v-picture =  substitute("&1\&2" ,Path-To-Dir-Pictures, entry(1,v-value) ) .
    end.
    else 
    do:
        v-picture  = "".
    end.
    
    if p-print-gold = yes
        then 
    do:
        /*---START--------- Определили, золото это или нет и вычислили кол-во мест ---------------------*/
        find first buf_units no-lock
            where buf_units.unit-name = goods.unit-base
            .
        assign
            v-not-gold = ?
            .
        if lookup({&twounit}, buf_units.type) <> 0
            then 
        do:
            run get-cli-qnty in this-procedure
                (    input recid( doc-line )
                , output qnty-pl
                ).
            assign
                /*qnty-pl     = doc-line.cli-qnty*/
                v-not-gold = no
                .
        end.
        if lookup({&altunit}, buf_units.type) <> 0
            then 
        do:
            assign
                qnty-pl    = doc-line.doc-qnty
                v-not-gold = no
                .
        end.
        if  v-not-gold  = ?
            then 
        do:
            assign
                v-not-gold = yes
                .
        end.
    /*---END----------- Определили, золото это или нет и вычислили кол-во мест ---------------------*/
    end.
    /*---START--------- Очистили и заполнили temp-table с именем товара по строкам ---------------------*/
    
    
    assign
        v-gds-name = goods.gds-name
        .
    for each temp_gds-name exclusive-lock
        :
        delete temp_gds-name.
    end.
    create temp_gds-name.
    assign
        s1                       = breakstr( v-gds-name,  28, input-output temp_gds-name.gds-name, input-output s2)
        v-gds-name-counter       = 1
        temp_gds-name.string-num = 1
        .
    do while s2 <> "" :
        create temp_gds-name.
        assign
            s1                       = breakstr( input s2
                                                  , input 28
                                                  , input-output temp_gds-name.gds-name
                                                  , input-output s2
                                                  )
            v-gds-name-counter       = v-gds-name-counter + 1
            temp_gds-name.string-num = v-gds-name-counter
            .
    end. /* do while ... */
    find first temp_gds-name no-lock .
    
    
    /*---END----------- Очистили и заполнили temp-table с именем товара по строкам ---------------------*/
    
    find first gds-prt no-lock
        where gds-prt.upper-code = goods.prt-root
        .
    assign
        rootnode_code = gds-prt.node-code.
    .
    if costprice
        then 
    do:
        { str/in-vatp.i calc doc-line. t-doc. g}
        assign 
            PricendS = ( if PrintRubl then vat-rubl-loc else vat-base-loc ).
        if PricendS = ? then assign PricendS = 0.
        assign
            PricewithNDS = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
            PriceNoNDS   = PricewithNDS - PricendS
            .
    end.
    else 
    do:
        { str/out-vatp.i calc doc-line. t-doc.}
        assign 
            PricendS = ( if PrintRubl then vat-rubl-sale else vat-base-sale ).
        if PricendS = ? then assign PricendS = 0.
        assign
            PricewithNDS = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
            PriceNoNDS   = PricewithNDS - PricendS
            .
    end.
    
    if not can-do( {&empty-scale}, gds-prt.node-name )
        then 
    do:                                  /* Не пустая шкала */
        if PrintScale = yes
            then 
        do:
             
            /*        if costprice = yes                                                                                            */
            /*            then                                                                                                      */
            /*        do:                                                                                                           */
            /*            put stream OutStr-html unformatted                                                                        */
            /*                '       <tr level="' + string( g-level) + '" >' skip                                                  */
            /*                '         <td  style="display: yes; text-align:  right "> ' +   temp_gds-name.gds-name + '</td>'  skip*/
            /*                '         <td style="display: yes; text-align:  right ">'  +  goods.artic +  '  </td>' skip           */
            /*                '         <td style="display: yes; text-align:  right "> </td>' skip                                  */
            /*                '         <td  style="display: yes; text-align:  right "></td>'  skip                                 */
            /*                '         <td style="display: yes; text-align:  right "> </td>' skip                                  */
            /*                '         <td style="display: yes; text-align:  right "> </td>' skip                                  */
            /*                '         <td  style="display: yes; text-align:  right "></td>'  skip                                 */
            /*                '         <td style="display: yes; text-align:  right "></td>' skip                                   */
            /*                '       </tr>' skip                                                                                   */
            /*                .                                                                                                     */
            /*        end.        /* costprice = yes */                                                                             */
            /*        else                                                                                                          */
            /*        do:                                                                                                           */
            /*            put stream OutStr-html unformatted                                                                        */
            /*                '       <tr level="' + string( g-level) + '" >' skip                                                  */
            /*                '         <td  style="display: yes; text-align:  right "> ' +   temp_gds-name.gds-name + '</td>'  skip*/
            /*                '         <td style="display: yes; text-align:  right ">'  +  goods.artic +  '  </td>' skip           */
            /*                '         <td style="display: yes; text-align:  right "> </td>' skip                                  */
            /*                '         <td  style="display: yes; text-align:  right "></td>'  skip                                 */
            /*                '         <td style="display: yes; text-align:  right "> </td>' skip                                  */
            /*                '         <td style="display: yes; text-align:  right "> </td>' skip                                  */
            /*                '         <td  style="display: yes; text-align:  right "></td>'  skip                                 */
            /*                '         <td style="display: yes; text-align:  right "></td>' skip                                   */
            /*                '       </tr>' skip                                                                                   */
            /*                .                                                                                                     */
            /*        end.                                                                                                          */
            /*                                                                                                                      */
                        
            for each gds-dtl no-lock
                where gds-dtl.prod-type = doc-line.prod-type
                and gds-dtl.prod-code = doc-line.prod-code
                and gds-dtl.artic = doc-line.artic
                and gds-dtl.doc-code = doc-line.doc-code
                :
                find first gds-prt no-lock
                    where gds-prt.node-code = gds-dtl.prt-code
                    .

                assign
                    prt-tqnty      = gds-dtl.fact-qnty
                    prt-SumNoNDS   = PriceNoNDS * prt-tqnty
                    prt-SumNDS     = PricendS * prt-tqnty
                    prt-SumwithNDS = PricewithNDS * prt-tqnty
                    .
                assign
                    sum-prt-tqnty      = sum-prt-tqnty      +  prt-tqnty
                    sum-prt-SumNoNDS   = sum-prt-SumNoNDS   +  prt-SumNoNDS
                    sum-prt-SumNDS     = sum-prt-SumNDS     +  prt-SumNDS
                    sum-prt-SumwithNDS = sum-prt-SumwithNDS +  prt-SumwithNDS
                    .
                if PrintScale = yes
                    then 
                do:
                    find first bar-code no-lock
                        where bar-code.gds-code  = goods.gds-code
                        and bar-code.unit-cli  = goods.unit-base
                        and bar-code.node-code = gds-dtl.prt-code
                        and bar-code.part-code = ""
                        and bar-code.in-code   = ""
                        .
                    assign
                        PrtName = goods.gds-name + "//" + gds-prt.f-name
                        .
                    assign
                        Pg-tqnty      = Pg-tqnty +  prt-tqnty 
                        Pg-SumNoNDS   = Pg-SumNoNDS +  prt-SumNoNDS 
                        Pg-SumWithNDS = Pg-SumWithNDS +   prt-SumwithNDS
                        .
            
                    if costprice = yes
                        then 
                    do:
                        put stream OutStr-html unformatted
                            '       <tr level="' + string( g-level) + '" >' skip
                            '         <td  style="display: yes; text-align:  right "> ' +  goods.artic  + '</td>'  skip
                            '         <td style="display: yes; text-align:  right ">'  +   temp_gds-name.gds-name  +  '  </td>' skip
                            '<td>' skip
                            '<img src="' + v-picture + '"; alt="HTML5 Icon"  align="right" style="height:128px;  "/>'
                            ' </td>' skip 
                            '         <td style="display: yes; text-align:  right ">'  + string( bar-code.b-code ) + ' </td>' skip
                            '         <td  style="display: yes; text-align:  right ">' + goods.unit-base + '</td>'  skip 
                            '         <td style="display: yes; text-align:  right ">'    +  if  prt-tqnty  <> ?  then fnc-convert-dot-to-colon(prt-tqnty, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                            '         <td style="display: yes; text-align:  right "> '   +  if  PricewithNDS <> ?  then fnc-convert-dot-to-colon(PricewithNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip  
                            '         <td  style="display: yes; text-align:  right "> '  +  if  prt-SumNoNDS <> ?  then fnc-convert-dot-to-colon(prt-SumNoNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip  
                            '         <td style="display: yes; text-align:  right ">' +  if  prt-SumwithNDS <> ?  then fnc-convert-dot-to-colon( prt-SumwithNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                            
                            '       </tr>' skip
                            .
                    /*                            { rep/torg-13x.i prt- cost}*/
                    end.        /* costprice = yes */
                    else 
                    do: 
                        put stream OutStr-html unformatted
                            '       <tr level="' + string( g-level) + '" >' skip
                            '         <td  style="display: yes; text-align:  right "> ' +  goods.artic  + '</td>'  skip
                            '         <td style="display: yes; text-align:  right ">'  +  temp_gds-name.gds-name +  '  </td>' skip
                            '<td>' skip
                            '<img src="' + v-picture + '"; alt="HTML5 Icon"  align="right" style="height:128px;  "/>'
                            ' </td>' skip 
                        
                            '         <td style="display: yes; text-align:  right ">'  + string( bar-code.b-code ) + ' </td>' skip
                            '         <td  style="display: yes; text-align:  right ">' + goods.unit-base + '</td>'  skip
                            '         <td style="display: yes; text-align:  right ">'    +  if  prt-tqnty  <> ?  then fnc-convert-dot-to-colon(prt-tqnty, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                            '         <td style="display: yes; text-align:  right "> '   +  if  PricewithNDS <> ?  then fnc-convert-dot-to-colon(PricewithNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip  
                            '         <td  style="display: yes; text-align:  right "> '  +  if  prt-SumNoNDS <> ?  then fnc-convert-dot-to-colon(prt-SumNoNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip  
                            '         <td style="display: yes; text-align:  right ">' +  if  prt-SumwithNDS <> ?  then fnc-convert-dot-to-colon( prt-SumwithNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                            
                            '       </tr>' skip
                          
                            .
                    /*                            { rep/torg-13x.i prt- doc}*/
                        
                    end.
                end.       /* PrintScale = yes */
            end.        /*for each gds-dtl ...*/

            assign
                tqnty      = sum-prt-tqnty
                SumNoNDS   = sum-prt-SumNoNDS
                SumNDS     = sum-prt-SumNDS
                SumwithNDS = sum-prt-SumwithNDS
                .
                        
                        
                        
        end.
        if  PrintScale = no
            then 
        do:
            find bar-code where bar-code.gds-code  = goods.gds-code
                and bar-code.unit-cli  = goods.unit-base
                and bar-code.node-code = rootnode_code
                and bar-code.part-code = ""
                and bar-code.in-code   = ""
                no-lock .
            
            assign
                Pg-tqnty      = Pg-tqnty +  tqnty 
                Pg-SumNoNDS   = Pg-SumNoNDS +  SumNoNDS 
                Pg-SumWithNDS = Pg-SumWithNDS +   SumwithNDS
                .
            if costprice = yes
                then 
            do:
                put stream OutStr-html unformatted
                    '       <tr level="' + string( g-level) + '" >' skip
                    '         <td  style="display: yes; text-align:  right "> ' +   goods.artic + '</td>'  skip
                    '         <td style="display: yes; text-align:  right ">'  +  temp_gds-name.gds-name  +  '  </td>' skip
                    '<td>' skip
                    '<img src="' + v-picture + '"; alt="HTML5 Icon"  align="right" style="height:128px;  "/>'
                    ' </td>' skip 
                    '         <td style="display: yes; text-align:  right ">'  + string( bar-code.b-code ) + ' </td>' skip
                    '         <td  style="display: yes; text-align:  right ">' + goods.unit-base + '</td>'  skip
                    '         <td style="display: yes; text-align:  right ">'    +  if tqnty  <> ?  then fnc-convert-dot-to-colon(tqnty, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right "> '   +  if  PricewithNDS <> ?  then fnc-convert-dot-to-colon(PricewithNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip  
                    '         <td  style="display: yes; text-align:  right "> '  +  if  SumNoNDS <> ?  then fnc-convert-dot-to-colon(SumNoNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip  
                    '         <td style="display: yes; text-align:  right ">' +  if  SumwithNDS <> ?  then fnc-convert-dot-to-colon( SumwithNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                            
                    '       </tr>' skip
                          
                    .
            end.
     
            else 
            do:
                put stream OutStr-html unformatted
                
                    '       <tr level="' + string( g-level) + '" >' skip
                    '         <td  style="display: yes; text-align:  right "> ' +  goods.artic  + '</td>'  skip
                    '         <td style="display: yes; text-align:  right ">'  +   temp_gds-name.gds-name  +  '  </td>' skip
                    '<td>' skip
                    '<img src="' + v-picture + '"; alt="HTML5 Icon"  align="right" style="height:128px;  "/>'
                    ' </td>' skip 
                    '         <td style="display: yes; text-align:  right ">'  + string( bar-code.b-code ) + ' </td>' skip
                    '         <td  style="display: yes; text-align:  right ">' + goods.unit-base + '</td>'  skip
                    '         <td style="display: yes; text-align:  right ">'    +  if  tqnty  <> ?  then fnc-convert-dot-to-colon(tqnty, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right "> '   +  if  PricewithNDS <> ?  then fnc-convert-dot-to-colon(PricewithNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip  
                    '         <td  style="display: yes; text-align:  right "> '  +  if SumNoNDS <> ?  then fnc-convert-dot-to-colon(SumNoNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip  
                    '         <td style="display: yes; text-align:  right ">' +  if  SumwithNDS <> ?  then fnc-convert-dot-to-colon( SumwithNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                            
                    '       </tr>' skip
                          
                    .
            end.
        end.
    end.
    else 
    do:  /* пустая шкала */
        find first bar-code no-lock
            where bar-code.gds-code = goods.gds-code
            and bar-code.unit-cli = goods.unit-base
            and bar-code.node-code = rootnode_code
            and bar-code.part-code = ""
            and bar-code.in-code = ""
            .
        find first gds-dtl no-lock
            where gds-dtl.doc-code = doc-line.doc-code
            and gds-dtl.prod-type = doc-line.prod-type
            and gds-dtl.prod-code = doc-line.prod-code
            and gds-dtl.artic = doc-line.artic
            and gds-dtl.prt-code = rootnode_code
            .
        assign
            tqnty      = gds-dtl.fact-qnty
            unit-str   = goods.unit-base
            SumNoNDS   = PriceNoNDS * tqnty
            SumNDS     = PricendS * tqnty
            SumwithNDS = PricewithNDS * tqnty
            .
        assign
            Pg-tqnty      = Pg-tqnty +  tqnty 
            Pg-SumNoNDS   = Pg-SumNoNDS +  SumNoNDS 
            Pg-SumWithNDS = Pg-SumWithNDS +   SumwithNDS
            Pg-SumNDS     = Pg-SumNDS +  SumNDS 
              
            .
              
        if costprice = yes
            then 
        do:
            put stream OutStr-html unformatted
                '       <tr level="' + string( g-level) + '" >' skip
                '         <td  style="display: yes; text-align:  right "> ' +   goods.artic  + '</td>'  skip
                '         <td style="display: yes; text-align:  right ">'  + temp_gds-name.gds-name  +  '  </td>' skip
                '<td>' skip
                '<img src="' + v-picture + '"; alt="HTML5 Icon"  align="right" style="height:128px;  "/>'
                ' </td>' skip 
                '         <td style="display: yes; text-align:  right ">'  + string( bar-code.b-code ) + ' </td>' skip
                '         <td  style="display: yes; text-align:  right ">' + goods.unit-base + '</td>'  skip
                '         <td style="display: yes; text-align:  right ">'    +  if  tqnty  <> ?  then fnc-convert-dot-to-colon(tqnty, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td style="display: yes; text-align:  right "> '   +  if  PricewithNDS <> ?  then fnc-convert-dot-to-colon(PricewithNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip  
                '         <td  style="display: yes; text-align:  right "> '  +  if SumNoNDS <> ?  then fnc-convert-dot-to-colon(SumNoNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip  
                '         <td style="display: yes; text-align:  right ">' +  if  SumwithNDS <> ?  then fnc-convert-dot-to-colon( SumwithNDS , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                            
                '       </tr>' skip
                          
                .
                                 
        end.
        else 
        do:
            put stream OutStr-html unformatted
                        
                '       <tr level="' + string( g-level) + '" >' skip
                '         <td  style="display: yes; text-align:  right "> ' +  goods.artic  + '</td>'  skip
                '         <td style="display: yes; text-align:  right ">'  +   temp_gds-name.gds-name +  '  </td>' skip
                '<td>' skip
                '<img src="' + v-picture + '"; alt="HTML5 Icon"  align="right" style="height:128px;  "/>'
                ' </td>' skip 
                '         <td style="display: yes; text-align:  right ">'  + string( bar-code.b-code ) + ' </td>' skip
                '         <td  style="display: yes; text-align:  right ">' + goods.unit-base + '</td>'  skip                        
                '         <td style="display: yes; text-align:  right ">'    +  if  tqnty  <> ?  then fnc-convert-dot-to-colon( tqnty , "->>>>>>>9" ) + '</td>' else "?" + '</td>' skip
                '         <td style="display: yes; text-align:  right "> '   +  if  PricewithNDS <> ?  then fnc-convert-dot-to-colon( PricewithNDS , "->>>>>>>9.99" ) + '</td>' else "?" + '</td>' skip  
                '         <td  style="display: yes; text-align:  right "> '  +  if SumNoNDS <> ?  then fnc-convert-dot-to-colon( SumNoNDS , "->>>>>>>9.99" ) + '</td>' else "?" + '</td>' skip  
                '         <td style="display: yes; text-align:  right ">' +  if  SumwithNDS <> ?  then fnc-convert-dot-to-colon( SumwithNDS , "->>>>>>>9.99" )  + '</td>' else "?" + '</td>' skip                            
                '       </tr>' skip
                          
                .
                                 
        end.
    end.               
                                 
    assign
        sum-tqnty      = sum-tqnty       + tqnty
        sum-SumNoNDS   = sum-SumNoNDS    + SumNoNDS
        sum-SumNDS     = sum-SumNDS      + SumNDS
        sum-SumwithNDS = sum-SumwithNDS  + SumwithNDS
        .

end procedure. /* print-doc-line */
 
 
if PrintRubl then
    run rep/wp-rub.p ( sum-SumwithNDS, output s1, output s2 ) .
else
    run rep/wp.p ( input  parparentproc  , sum-SumwithNDS, output s1, output s2 ) .
 
 
/* Не пустая шкала */
do:
    put stream OutStr-html unformatted
     
        '       <tr >' skip
        '         <td   style="display: yes; text-align: left; font-weight: bold;"></td>'  skip
           
        '         <td colspan = "4"  style="display: yes; text-align: left; font-weight: bold;"> Итого:</td>'  skip
        '         <td style="display: yes; font-weight: bold; text-align:  right ">'    +  if  Pg-tqnty  <> ?  then fnc-convert-dot-to-colon( Pg-tqnty , "->>>>>>>9" ) + '</td>' else "?" + '</td>' skip
        '         <td   style="display: yes; text-align: left; font-weight: bold;"></td>'  skip
                  
        '         <td  style="display: yes; font-weight: bold; text-align:  right "> '  +  if Pg-SumNoNDS <> ?  then fnc-convert-dot-to-colon( Pg-SumNoNDS , "->>>>>>>9.99" ) + '</td>' else "?" + '</td>' skip  
        '         <td style="display: yes; font-weight: bold; text-align:  right ">' +  if   Pg-SumWithNDS <> ?  then fnc-convert-dot-to-colon(  Pg-SumWithNDS  , "->>>>>>>9.99" )  + '</td>' else "?" + '</td>' skip                            
                           
                  
         
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '       <tr >' skip
        '         <td   style="display: yes; text-align: left; font-weight: bold;"></td>'  skip
           
        '         <td colspan = "4"  style="display: yes; text-align: left; font-weight: bold;">Всего по накладной:</td>'  skip
        '         <td style="display: yes; font-weight: bold; text-align:  right ">'    +  if  t-doc.fact-qnty    <> ?  then fnc-convert-dot-to-colon(t-doc.fact-qnty   , "->>>>>>>9" ) + '</td>' else "?" + '</td>' skip
        '         <td   style="display: yes; text-align: left; font-weight: bold;"></td>'  skip
                  
        '         <td  style="display: yes; font-weight: bold; text-align:  right "> '  +  if sum-SumNoNDS  <> ?  then fnc-convert-dot-to-colon( sum-SumNoNDS  , "->>>>>>>9.99" ) + '</td>' else "?" + '</td>' skip  
        '         <td style="display: yes; font-weight: bold; text-align:  right ">' +  if    sum-SumwithNDS <> ?  then fnc-convert-dot-to-colon(   sum-SumwithNDS  , "->>>>>>>9.99" )  + '</td>' else "?" + '</td>' skip                            
                           
                  
         
        '</tr>' skip
        .
    put stream OutStr-html unformatted
           
        '<body>'
     '<thead>'
     '<TR style="height: 30pt;">'skip     
     '<TD style="text-align: left;border: none"></TD>'skip
     '<TD style="text-align: left;border:none;"></TD>'skip
     '<TD style="text-align: left;border:none;"></TD>'skip
     '<TD style="text-align: left;border:none;"></TD>'skip
     '<TD style="text-align: left;border: none"></TD>'skip
     '<TD  style="text-align: left;border: none"></TD>'skip
     '<TD  style="text-align: left;border: none"></TD>'skip
         
     '</TR>'skip
     
     '<TR>'skip     
     '<TD style="text-align: left;border: none">Отпустил</TD>'skip
     '<TD style="text-align: left;border:none; border-bottom: 1px solid black;font-weight: bold;"></TD>'skip
     '<TD style="text-align: left;border:none; border-bottom: 1px solid black;font-weight: bold;"></TD>'skip
     '<TD style="text-align: left;border: none"> </TD>'skip
     
     '<TD style="text-align: left;border:none; border-bottom: 1px solid black;font-weight: bold;"></TD>'skip
     '<TD style="text-align: left;border: none"> </TD>'skip
          '<TD style="text-align: left;border: none"> </TD>'skip   
     
     '<TD style="text-align: left;border:none; border-bottom: 1px solid black;font-weight: bold;"></TD>'skip
         
     '</TR>'skip
    
     '<TR>'skip     
     '<TD style="text-align: left;border: none"></TD>'skip
     '<TD colspan = "2" style="text-align: center;border:none;font-weight: bold;font-size:7pt;">должность</TD>'skip
          '<TD style="text-align: left;border: none"> </TD>'skip
     '<TD style="text-align: center;border:none;font-weight: bold;font-size:7pt;">подпись</TD>'skip
     '<TD style="text-align: left;border: none"> </TD>'skip   
          '<TD style="text-align: left;border: none"> </TD>'skip   
     
     '<TD style="text-align: center;border:none;font-weight: bold;font-size:7pt;">расшифровка подписи</TD>'skip
     '<TD  style="text-align: left;border: none"> </TD>'skip
     '<TD  style="text-align: left;border: none"> </TD>'skip
         
     '</TR>'skip
     
     '<TR>'skip     
     '<TD colspan = "3" style="text-align: left;border: none">товар и тару по количеству и надлежащему качеству на сумму:</TD>'skip
     '<TD colspan = "6" style="text-align: left;border: none"> ' + s1 + '</TD>'skip
         
     '</TR>'skip
     
     
     '<TR style="height: 30pt;" >'skip     
     '<TD style="text-align: left;border: none"></TD>'skip
     '<TD style="text-align: left;border:none;"></TD>'skip
     '<TD style="text-align: left;border:none;"></TD>'skip
     '<TD style="text-align: left;border:none;"></TD>'skip
     '<TD style="text-align: left;border: none"></TD>'skip
     '<TD  style="text-align: left;border: none"></TD>'skip
     '<TD  style="text-align: left;border: none"></TD>'skip
         
     '</TR>'skip
     
         '<TR>'skip     
     '<TD style="text-align: left;border: none">Получил</TD>'skip
     '<TD style="text-align: left;border:none; border-bottom: 1px solid black;font-weight: bold;"></TD>'skip
     '<TD style="text-align: left;border:none; border-bottom: 1px solid black;font-weight: bold;"></TD>'skip
     '<TD style="text-align: left;border: none"> </TD>'skip
     
     '<TD style="text-align: left;border:none; border-bottom: 1px solid black;font-weight: bold;"></TD>'skip
     '<TD style="text-align: left;border: none"> </TD>'skip
          '<TD style="text-align: left;border: none"> </TD>'skip   
     
     '<TD style="text-align: left;border:none; border-bottom: 1px solid black;font-weight: bold;"></TD>'skip
         
     '</TR>'skip
    
     '<TR>'skip     
     '<TD style="text-align: left;border: none"></TD>'skip
     '<TD colspan = "2" style="text-align: center;border:none;font-weight: bold;font-size:7pt;">должность</TD>'skip
          '<TD style="text-align: left;border: none"> </TD>'skip
     '<TD style="text-align: center;border:none;font-weight: bold;font-size:7pt;">подпись</TD>'skip
     '<TD style="text-align: left;border: none"> </TD>'skip  
          '<TD style="text-align: left;border: none"> </TD>'skip   
      
     '<TD style="text-align: center;border:none;font-weight: bold;font-size:7pt;">расшифровка подписи</TD>'skip
     '<TD  style="text-align: left;border: none"> </TD>'skip
     '<TD  style="text-align: left;border: none"> </TD>'skip
         
     '</TR>'skip
 .
 
 
end.
 
 
 
 
                    
do: 
    put stream OutStr-html unformatted
        '</tbody>'
        '   </table>' skip
        '  </body>' skip
        ' </html>' skip
        . /* Точка для закрытия Put */
    output stream OutStr-html close.
end.              
         
         
         
         
procedure print-group-line :
    do
        on error undo, return error
        :
        put stream OutStr-html unformatted
            '       <tr level="' + string( p-level) + '" >' skip
            '         <td colspan = "8"  style="display: yes; text-align: left; font-weight: bold;"> ' +     goods.grp-name  + '</td>'  skip
            '</tr>' skip
      
            .
    end.
end procedure. /* print-group-line */
         
procedure print-prod-line :
    do
        on error undo, return error
        :
        put stream OutStr-html unformatted
            '       <tr level="1" >' skip
            '         <td  colspan = "8" style="display: yes; text-align: left; font-weight: bold; "> ' +    string(clients.obj-code) + "  " + clients.obj-name + '</td>'  skip
            '</tr>' skip
            .
    /*  down stream out-stream 1 with frame f-doc .*/
    end.
end procedure. /* print-group-line */
                
run search-full-path-Report(input v-report-name-html).
run Report-Viewer(input v-full-path-RepView, input v-report-name-html).
  
  
function fnc-DD-MM-YYYY returns character 
    (input p-dat-date as date):
    /* Преобразование даты в формат: "01.01.2014" */

    define variable result     as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

    return p-str-date.

end function.

function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character):
    /* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - точность) */

    define variable result       as character no-undo.
    define variable v-str-result as character no-undo.
    /*message "dbg-p-data = " p-data skip "p-accur = " p-accur view-as alert-box.*/
    p-data = round(p-data, 2). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).

    return v-str-result.

end function.
 
procedure create-file:              /* СоздЛюбогоФайлаНаДиске(input полный_путь_с_именем) */
    /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

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

procedure define-full-path-Report:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
    /* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.  
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

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
                    
                    
                         
                        
    