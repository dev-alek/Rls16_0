block-level on error undo, throw.
/*

$Revision: a8e2cf75ddf6, 2506, rls $
$Author: EShklyar $
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: r-pr-akt.p $
$Archive: rep/r-pr-akt.p $

Печать акта и протокола переоценки

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Input:

Output:
 
*/

define input parameter parparentproc     as handle           no-undo.
define input parameter rec_id            as recid            no-undo.
define input parameter p-doc-type        as character        no-undo.    /* akt - акт, prik - приказ,                    */
define input parameter p-price-celection as integer          no-undo.
define input parameter p-print-null-qnty as logical          no-undo.
define input parameter p-sort-by-group   as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-pr-akt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-pr-akt.p $":U .
define variable vss-description as character no-undo init "Печать акта и протокола переоценки".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ gbl/cur-time.i    }
{ cmp/r-pril.i new  }
{ cmp/croslist.i    }
{ str/hvrdtax.i     }
{ gbl/tax-name.i    }
{ gbl/dtm.i         }
{ str/writelog.i def "'r-akt.log'" }
{ rep/r-akt.i def   }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/*do                         */
/*on error undo, return error*/
/*:                          */

def buffer old-list    for price-list.
def buffer buf_clients for clients.

def shared var      sort-gr              as logical no-undo.

    
    define variable v-kol as integer.
    define variable v-procent as decimal.
def        var      v-old-sum            as decimal no-undo.
def        var      v-new-sum            as decimal no-undo.
def        var      v-del-sum            as decimal no-undo.
def        var      v-up-fact            as decimal no-undo.

def        var      propis               as char    no-undo.
def        var      abbr                 as char    no-undo.
def        var      v-single-line        as char    no-undo.
def        var      v-b-code             as char    no-undo.

def        var      v-line-counter       as int     no-undo.
def        var      v-good-line-counter  as int     no-undo.

define     variable p-procent            as decimal.
def        var      sym1                 as char    init ":" no-undo.
def        var      sym2                 as char    init ":" no-undo.
def        var      sym3                 as char    init ":" no-undo.
def        var      sym4                 as char    init ":" no-undo.
def        var      sym5                 as char    init ":" no-undo.
def        var      sym6                 as char    init ":" no-undo.
def        var      sym7                 as char    init ":" no-undo.
def        var      sym8                 as char    init ":" no-undo.
def        var      sym9                 as char    init ":" no-undo.
def        var      sym10                as char    init ":" no-undo.

def        var      Log-Res1             as logical no-undo.
def        var      v-print-cost-price   as logical no-undo.
define     variable akt                  as char.
define     variable prik                 as char.
def        var      v-shift-down         as logical init yes no-undo.
def        var      v-print-group        as logical init yes no-undo.

define variable  v-price-sale as decimal.
define variable   v-gds-price-sale as decimal.
            

define variable v-price-sum-list as decimal.
define variable v-price-sum-last as decimal.
def        var      v-price-doc-doc-num  like price-doc.doc-num no-undo.
def        var      v-price-doc-doc-date like price-doc.doc-date no-undo.

define variable p-number as integer init 0.
def        var      v-main-price-sale    like price-list.price-sale no-undo.

define     variable g#report-num         as integer no-undo.
define     variable g#quest-print        as logical no-undo.
define     variable g#log                as logical no-undo.

define     variable v-rb-is-base         as logical no-undo.
define stream outstr-html.
def stream AktStr .
define variable v-report-name-html  as char.
define variable v-full-path-RepView as char.

/* ************************  Function Implementations ***************** */
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



{ gbl/rbisbase.i
    v-rb-is-base
}

find first price-doc no-lock
    where recid(price-doc) = rec_id .
if not available price-doc
    then 
do:
    bell.
    message 'Порушена табличка "price-doc"(r-akt.p).'.
    return error.
end.
assign
    v-price-doc-doc-num  = price-doc.doc-num
    v-price-doc-doc-date = price-doc.doc-date
    .

find    clients no-lock
    where clients.obj-code = price-doc.obj-code
    and clients.obj-type = price-doc.obj-type
    .
if not available clients then
do:
    bell.
    message 'Порушена табличка "clients" (r-akt.p).'.
    return error.
end.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_overvalue-cast_print':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  Log-Res1
}

if ( price-doc.status_ = {&act-overvalue} )
    or Log-Res1
    then 
do:
    if  p-price-celection = 2
        then 
    do:
        assign 
            v-print-cost-price = TRUE .
    end.
    else 
    do:
        assign 
            v-print-cost-price = FALSE .
    end.
end.

find    trn-doc no-lock
    where trn-doc.doc-code = price-doc.doc-num
    no-error.

/*v-report-name-html = session:temp-directory + {&DF_Name} + string(g#report-num) + ".html". /*формирование имя файла для часть1*/*/
/*  if p-doc-type = prik then do:*/
       
do:
    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8'.
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
        '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 14px; ' + chr(125) skip
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
        .
end.        



            
    put stream OutStr-html unformatted
        ' <body>' skip
        '   <table name="Лист1" fit_to_page="true" orientation="Portrait" outline_below="false">' skip
        
        '     <thead>' skip
        '       <tr class="set_columns">' skip                 
        '         <td style="width: 80px; border: none;"></td>' skip    /*№*/       
        '         <td style="width: 80px; border: none;"></td>' skip    /*Код*/
        '         <td style="width: 320px; border: none;"></td>' skip      /*Артикул*/
        '         <td style="width: 80px; border: none;"></td>' skip    /* Название товара*/
        '         <td style="width: 100px; border: none;"></td>' skip   /*Количество*/
        '         <td style="width: 100px; border: none;"></td>' skip  /*Старая продажная цена*/
        
        '         <td style="width: 100px; border: none;"></td>' skip  /*Новая прод.цена*/
        '         <td style="width: 100px; border: none;"></td>' skip  /*Новая прод.цена*/
        '         <td style="width: 100px; border: none;"></td>' skip  /*Новая прод.цена*/
        '         <td style="width: 100px; border: none;"></td>' skip  /*Новая прод.цена*/

        '       </tr>' skip
        .
        
      
    do:  
        find    buf_clients no-lock
            where buf_clients.obj-type = {&cmp}
            and buf_clients.obj-code = price-doc.host-code
            .

        put stream OutStr-html unformatted
    
    
            '       <tr>' skip
            '         <td colspan="3" style="border: none; height: 14px;  text-align: center;  font-size: 12pt; border-bottom: 1px solid black;  font-weight: bold">' +   buf_clients.obj-name  + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
         
            '</tr>' skip

    
        '       <tr style="height: 30pt;">' skip
    
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
    
    
        '       <tr style="height: 30pt;">' skip
    
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
    
    
            '<tr>' skip
            '         <td colspan="9" style="border: none; height: 14px;  text-align: center;  font-size: 12pt; font-weight: bold">   А К Т  переоценки  по  остаткам   '
            +  ( if available trn-doc then string( "по документу N " + trn-doc.doc-code )
            else " " ) + "  в  " + clients.obj-name  +    '</td>' skip
                       
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip


            '       <tr>' skip
            '         <td colspan="9" style="border: none; height: 14px;  text-align: left;   font-size: 12pt; font-weight: bold">Номер ' + price-doc.doc-num
            "  от  " + fnc-DD-MM-YYYY(price-doc.doc-date )   + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
        
            '       <tr>' skip
            '         <td colspan="9" style="border: none; height: 14px;  text-align: left;  font-size: 12pt;  font-weight: bold">Дата печати: ' +   fnc-DD-MM-YYYY(today )   + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
            '     </thead>' skip
            .    
    end.

    if  v-print-cost-price = no then 
    do:
        put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr style="height: 60px;">' skip
            '         <th   style="background-color:#ffffcc; text-align: center">Код</th>' skip
            '         <th     style="background-color:#ffffcc; text-align: center">Артикул</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Название товара</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Количество</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Старая продажная цена</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Старая сумма продажной цены</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Новая продажная цена</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Новая сумма продажной цены</th>' skip
            '         <th   style="background-color:#ffffcc; text-align: center">Процент разницы</th>' skip
            '</tr>' skip
            .
        output stream OutStr-html close.

    end.
    else 
    do: 
    
        put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr style="height: 60px;">' skip
            '         <th   style="background-color:#ffffcc; text-align: center">Код</th>' skip
            '         <th     style="background-color:#ffffcc; text-align: center">Артикул</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Название товара</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Количество</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Последняя учетная цена</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Сумма учетных цен</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Новая продажная цена</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Новая сумма продажной цены</th>' skip
            '         <th   style="background-color:#ffffcc; text-align: center">Процент разницы</th>' skip
            '</tr>' skip
            .
        output stream OutStr-html close.
    
    end.
    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8'.
    
    
    
    if p-sort-by-group = yes       /*Кому сортировку по группам?*/
        then 
    do:
        for each price-list no-lock
            where price-list.doc-num = price-doc.doc-num
            , each goods no-lock
            where goods.artic     = price-list.artic
            and goods.prod-type = price-list.prod-type
            and goods.prod-code = price-list.prod-code
            break by goods.grp-name by goods.artic descending
            :
            assign
                v-print-group = (if first-of (goods.grp-name) then yes else no)
                .
            { rep/r-akt.i calc}
            if v-code-is-main = yes
                then 
            do:
            
                accumulate ( ( price-list.price-sale - v-price-list-price-sale_old ) * price-list.doc-qnty ) (total)
                    ( price-list.doc-qnty ) (total)
                    ( price-list.doc-qnty * v-price-list-price-sale_old ) (total)
                    ( price-list.doc-qnty * price-list.price-sale ) (total)
                    ( price-list.doc-qnty * v-gds-obj-last-price ) (total) .

                run print-line-fact in this-procedure.

            end.                /* if v-code-is-main */
        end.                  /* for each price-list where ... */
    end.            /*if sort-gr = yes */
    else 
    do:
       
        for each price-list no-lock
            where price-list.doc-num = price-doc.doc-num
            , each goods no-lock
            where goods.artic     = price-list.artic
            and goods.prod-type = price-list.prod-type
            and goods.prod-code = price-list.prod-code
            break by goods.artic descending
            :
            { rep/r-akt.i calc}
            if v-code-is-main = yes
                then 
            do:
                accumulate ( ( price-list.price-sale - v-price-list-price-sale_old ) * price-list.doc-qnty ) (total)
                    ( price-list.doc-qnty ) (total)
                    ( price-list.doc-qnty * v-price-list-price-sale_old ) (total)
                    ( price-list.doc-qnty * price-list.price-sale ) (total)
                    ( price-list.doc-qnty * v-gds-obj-last-price ) (total) .

                run print-line-fact in this-procedure.
            end.                /* if v-code-is-main */
        end.                  /* for each price-list where ... */
    end.
    
do:
    put stream OutStr-html unformatted
        '</tbody>' skip
        '</body>'
        .
         
end.
    
if v-print-cost-price = no then 
    assign v-procent =   (v-new-sum - v-old-sum) / v-old-sum * 100.
else
    assign v-procent =   (v-old-sum - v-new-sum) / v-new-sum * 100.
   
if v-print-cost-price = no then 
do:
    
     if v-rb-is-base = yes
        then do:
            run rep/wp.p (
                  input parparentproc
                , input absolute( accum total ( ( price-list.price-sale - v-price-list-price-sale_old) * price-list.doc-qnty) )
                , output propis
                , output abbr
            ) .
        end.        /* if v-rb-is-base = yes */
        else do:
            run rep/wp-rub.p (
                  input absolute( accum total ( ( price-list.price-sale - v-price-list-price-sale_old) * price-list.doc-qnty) )
                , output propis
                , output abbr
            ) .
            end.
         
    do:
        put stream OutStr-html unformatted
            '<body>'
            '<thead>'
            '       <tr >' skip
        '         <td colspan = "3 " style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold "> Итого: </td>' skip
            '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold ">'  + if      v-kol   <> ?  then fnc-convert-dot-to-colon(   v-kol  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                                         
            '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold"></td>' skip 
            '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold  ">'  + if     v-old-sum  <> ?  then fnc-convert-dot-to-colon( v-old-sum , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip 
            '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold "> </td>' skip                                         
            '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold  ">'  + if    v-new-sum   <> ?  then fnc-convert-dot-to-colon(  v-new-sum   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                               
            '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold  ">'  + if     v-procent   <> ?  then fnc-convert-dot-to-colon(   v-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                    
            '       </tr>' skip
            '       <tr >' skip
            '         <td colspan="9" style="border: none"></td>' skip
            
            '       </tr>' skip
           
     
          
            '       <tr >' skip
            '         <td colspan="3" style="border: none; height: 14px;  text-align: right; font-size: 10pt; font-weight: bold">Сумма переоценки: </td>' skip        
            '         <td colspan = "6" STYLE="border: none; border-bottom: 1px solid black;   text-align: center">'  + propis + '</td>' skip
            '       </tr>' skip
            .
    end.
end.
else 
do: 
             
    put stream OutStr-html unformatted
        '<body>'
        '<thead>'
        '       <tr >' skip
        '         <td colspan = "3 " style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold "> Итого: </td>' skip
        '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold  ">'  + if      v-kol   <> ?  then fnc-convert-dot-to-colon(   v-kol  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                                         
        '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold "></td>' skip 
        '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold  ">'  + if     v-new-sum  <> ?  then fnc-convert-dot-to-colon( v-new-sum , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip 
        '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold  "> </td>' skip                                         
        '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold  ">'  + if    v-old-sum   <> ?  then fnc-convert-dot-to-colon(  v-old-sum   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                               
        '         <td style="display: yes; border: 1px solid black ; text-align:  right; font-size: 10pt; font-weight: bold  ">'  + if     v-procent   <> ?  then fnc-convert-dot-to-colon(   v-procent  , "->>>>>>>9.9") + '</td>' else "?" + '</td>' skip                    
        '       </tr>' skip
        '       <tr >' skip
        '         <td colspan="9" style="border: none"></td>' skip
            
        '       </tr>' skip
        .
end.
      
do:
    put stream OutStr-html unformatted
           '       <tr style="height: 30pt;" >' skip
        '         <td colspan="9" style="border: none"></td>' skip
            
        '       </tr>' skip
        
        
              '       <tr style="height: 30pt;" >' skip
        '         <td colspan="9" style="border: none"></td>' skip
            
        '       </tr>' skip
        
        '       <tr >' skip
        '         <td colspan="2" style="border: none; height: 14px;  text-align: right; font-size: 10pt; font-weight: bold">Председатель комиссии: </td>' skip
        '         <td style="border: none; border-bottom: 1px solid black"></td>' skip
        '         <td style="border: none"></td>' skip
/*        '         <td style="border: none"></td>' skip*/
        '         <td  colspan="2" style="border: none; height: 14px;  text-align: right; font-size: 10pt; font-weight: bold">Члены комиссии:</td>' skip
        '         <td colspan="2" style="border: none; border-bottom: 1px solid black"></td>' skip
        '         <td style="border: none; border-bottom: 1px solid black"></td>' skip           
        '       </tr>' skip
        
        .
        
end.
    
    
do: 
    put stream OutStr-html unformatted
        '</thead>'
        '   </table>' skip
        '  </body>' skip
        ' </html>' skip
        . /* Точка для закрытия Put */
    output stream OutStr-html close.
end.


procedure print-line-fact:
    
    if not can-find( first gds-prt where gds-prt.upper-code = v-gds-prt-node-code )
        then 
    do:                                                                              /* Т.е. пустая шкала */
        if ( price-list.doc-qnty <> 0 ) or ( p-print-null-qnty = yes )
            then 
        do:
      
            if v-print-cost-price
                then 
            do:
                v-price-sum-last =   ( price-list.doc-qnty * v-gds-obj-last-price ) .
                v-price-sum-list =    ( price-list.doc-qnty * price-list.price-sale ). 
                p-procent  = ( price-list.price-sale - v-gds-obj-last-price ) / v-gds-obj-last-price * 100.
            
            
            
           
                 
                v-old-sum = v-old-sum +  v-price-sum-list.
                v-new-sum = v-new-sum + v-price-sum-last.
                v-kol = v-kol +  price-list.doc-qnty .
            
                run writelog in this-procedure (log-file-name, 4, "Включена печать по учетным ценам").
                if p-sort-by-group = yes       /*Кому сортировку по группам?*/
                    then 
                do:
                    /*                { rep/r-akt.i group cost}*/
                    /*            end.                         */
                if v-print-group = yes then do:
    
       
   
                    put stream OutStr-html unformatted                                   
                        '       <tr level="1">' skip

                        '         <td colspan="9" style="border: none; height: 14px;  text-align: left; font-size: 10pt; font-weight: bold">' +  goods.grp-name  + '</td>' skip
         
                        '</tr>' skip
                        .
                   end.
                      put stream OutStr-html unformatted 
                      '       <tr level="2">' skip
                      '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                      '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                      '         <td style="display: yes; text-align:  left ">'  +        goods.gds-name + '</td>' skip
                      '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip 
                      '         <td style="display: yes; text-align:  right ">'  + if    v-gds-obj-last-price   <> ?  then fnc-convert-dot-to-colon(  v-gds-obj-last-price  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                                         
                      '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                      '         <td style="display: yes; text-align:  right ">'  + if    price-list.price-sale   <> ?  then fnc-convert-dot-to-colon(  price-list.price-sale   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                      '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                      
                      '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip             
                      '       </tr>' skip
                        .
                end.     
                else 
                do:  
                    put stream OutStr-html unformatted
                        '       <tr level="1">' skip
                    '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                    '         <td style="display: yes; text-align:  left ">'  +        goods.gds-name + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip 
                    '         <td style="display: yes; text-align:  right ">'  + if    v-gds-obj-last-price   <> ?  then fnc-convert-dot-to-colon(  v-gds-obj-last-price  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                                         
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                    '         <td style="display: yes; text-align:  right ">'  + if    price-list.price-sale   <> ?  then fnc-convert-dot-to-colon(  price-list.price-sale  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                    '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                    
                    '       </tr>' skip
                        .
                end.        
            end.      
            else 
            do:
                v-price-sum-last =    ( price-list.doc-qnty * price-list.price-sale )   .
                v-price-sum-list =    ( price-list.doc-qnty * v-price-list-price-sale_old ).
                p-procent  = ( price-list.price-sale - v-price-list-price-sale_old ) / v-price-list-price-sale_old * 100.
                
                v-old-sum = v-old-sum +  v-price-sum-list.
                v-new-sum = v-new-sum + v-price-sum-last.
                v-kol = v-kol +  price-list.doc-qnty .
                
                if p-sort-by-group = yes       /*Кому сортировку по группам?*/
                    then 
                do:
                    /*                { rep/r-akt.i group cost}*/
                    /*            end.                         */
            
                       if v-print-group = yes then do:
    
       
   
                    put stream OutStr-html unformatted                                   
                        '       <tr level="1">' skip

                        '         <td colspan="9" style="border: none; height: 14px;  text-align: left; font-size: 10pt; font-weight: bold">' +  goods.grp-name  + '</td>' skip
         
                        '</tr>' skip
                        .
                   end.
                      put stream OutStr-html unformatted
                  
                      '       <tr level="2">' skip
                      '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                      '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                      '         <td style="display: yes; text-align:  left ">'  +        goods.gds-name + '</td>' skip
                      '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip 
                      '         <td style="display: yes; text-align:  right ">'  + if     v-price-list-price-sale_old   <> ?  then fnc-convert-dot-to-colon(  v-price-list-price-sale_old  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                                         
                      '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                      '         <td style="display: yes; text-align:  right ">'  + if     price-list.price-sale   <> ?  then fnc-convert-dot-to-colon(  price-list.price-sale  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                                         
                      '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                      '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip             
                      '       </tr>' skip
                        .
                end.     
                else 
                do:  
                    put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                    '         <td style="display: yes; text-align:  left ">'  +        goods.gds-name + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip 
                    '         <td style="display: yes; text-align:  right ">'  + if     v-price-list-price-sale_old   <> ?  then fnc-convert-dot-to-colon(  v-price-list-price-sale_old  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                                         
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                    '         <td style="display: yes; text-align:  right ">'  + if     price-list.price-sale   <> ?  then fnc-convert-dot-to-colon(  price-list.price-sale  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                                         
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                
                    '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip             
                    '       </tr>' skip
                        .
                end.        
            end.      

        end.
    end.
    else 
    do:
        if ( price-list.doc-qnty <> 0 ) or ( p-print-null-qnty )
            then 
        do:  
                  
            if v-print-cost-price = yes
                then 
            do:
           
                v-price-sum-last =   ( price-list.doc-qnty * v-gds-obj-last-price ) .
                v-price-sum-list =   ( price-list.doc-qnty * price-list.price-sale ).  
                p-procent  = ( price-list.price-sale - v-gds-obj-last-price ) / v-gds-obj-last-price * 100.
                
            
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                    '         <td style="display: yes; text-align:  left ">'  +        goods.gds-name + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip 
                    '         <td style="display: yes; text-align:  right ">'  + if     price-list.price-sale   <> ?  then fnc-convert-dot-to-colon(  price-list.price-sale  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                                         
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-list-price-sale   <> ?  then fnc-convert-dot-to-colon(  v-price-list-price-sale   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                    '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                    
                    '       </tr>' skip
                    .
                
           
           
            end.
            else 
            do:
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                    '         <td style="display: yes; text-align:  left ">'  +        goods.gds-name + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip 
                    '         <td style="display: yes; text-align:  right ">'  + if     price-list.price-sale   <> ?  then fnc-convert-dot-to-colon(  price-list.price-sale  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                                         
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-list-price-sale   <> ?  then fnc-convert-dot-to-colon( v-price-list-price-sale   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                  
                    '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                     
                    '       </tr>' skip
                    .
            end.
        end.
    end.

end procedure.

      
       
run search-full-path-Report(input v-report-name-html).
run Report-Viewer(input v-full-path-RepView, input v-report-name-html).
  
  
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
