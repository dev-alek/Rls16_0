block-level on error undo, throw.
/*

$Revision: 992a74a9441b, 3581, rls $
$Author: VSpiridonov $
$Date: 2023/12/14 13:36:13 $
$Workfile: torg-15.p $
$Archive: rep/torg-15.p $

Печатные формы. Торг-15 для списания.

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/15/05
Author: Victor Guntner
Creation date: 09/15/05

Input:
    rec_id          as recid        - recid складского документа (trn-doc)

Output:

*/
do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: 992a74a9441b, 3581, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/14 13:36:13 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg-15.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/torg-15.p $":U .
define variable vss-description as character no-undo init "Печатные формы. Торг-15 для списания ".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/r-pril.i          }
{ str/trdcalib.i        }
{ str/in-vatp.i def     }
{ str/out-vatp.i def    }
{ rep/r-cliprp.i def    }
{ rep/fmtcli.i          }
{ gbl/clntattr.i        }
{ rep/torgconf.i        }
{ str/getctxtp.i def    }
{ gbl/prn-lib.i }
define stream Out-stream.

define buffer t-doc        for trn-doc.
define buffer b-trn-doc    for trn-doc.
define buffer OurObject    for clients.

define shared variable PrintScale      as logical                   no-undo.
define shared variable CostPrice       as logical                   no-undo.
define shared variable no-vat          as logical                   no-undo.

define variable v-base-code     as integer                          no-undo.

define variable rootnode_code   as integer                          no-undo.

define variable LineCounter     as integer                          no-undo.
define variable PrLineCounter   as integer                          no-undo.

define variable s1              as character                        no-undo.
define variable s2              as character                        no-undo.

define variable Node_Code       like gds-prt.upper-code             no-undo.

define variable tqnty           like ot-line.fact-qnty              no-undo.
define variable sumtqnty        like ot-line.fact-qnty              no-undo.
define variable price           like ot-line.sum-base               no-undo.
define variable price-Vat       like ot-line.VAT-base               no-undo.
define variable v-old-price     like ot-line.sum-base               no-undo.
/*define variable v-old-price-Vat like ot-line.VAT-base               no-undo.*/
define variable v-prices-are-different as logical                   no-undo.

define variable stoim           like ot-line.sum-base               no-undo.
define variable sumstoim        like ot-line.sum-base               no-undo.
define variable PropisStoim     as character                        no-undo.
define variable  abbr              as  char no-undo.
/*define variable stoim-Vat       like ot-line.VAT-base               no-undo.*/
define variable v-okei          as character                        no-undo.

define variable parts-cost      like ot-line.sum-base               no-undo.
define variable parts-Vat       like ot-line.VAT-base               no-undo.
define variable v-reason        as character                        no-undo. /*Причины списания. Должны браться из trn-doc.PS,*/
define variable v-reason-code   like trn-reason.reason-code         no-undo.                                                                     /*если первый символ не равен "@"*/
define variable prt-tqnty       like ot-line.fact-qnty              no-undo.
define variable prt-stoim       like ot-line.sum-base               no-undo.
/*define variable prt-stoim-Vat   like ot-line.VAT-base               no-undo.*/

define variable Pg-tqnty        like ot-line.fact-qnty      init 0  no-undo.
define variable Pg-stoim        like ot-line.sum-base       init 0  no-undo.
/*define variable Pg-stoim-Vat    like ot-line.VAT-base       init 0  no-undo.*/
define variable PrevPage        as int      init 0                  no-undo.

define variable stoim-totl      like ot-line.sum-base               no-undo.

define variable PrtName         as character                        no-undo.
define variable PrtNameXL       as character                        no-undo.

define variable OKEI            as character                        no-undo.
define variable tb-code         as character                        no-undo.
define variable qnty-pl         like ot-line.fact-qnty              no-undo.
define variable mass-b          as decimal  decimals 10             no-undo.
define variable mass-n          as decimal  decimals 10             no-undo.
define variable gds-PS          as character                        no-undo.
define variable date-in         as date                             no-undo.


define variable Line                as character           no-undo.
define variable UndLine             as character           no-undo.

define variable unit-str            as character           no-undo.
define variable val-str             as character           no-undo.
define variable tdoc-code           like trn-doc.doc-code  no-undo.
define variable v-doc-date-string   as character           no-undo.
define variable v-host-code         as integer             no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

/*переменные для отчета HTML*/
define stream Out-Stream.
define stream OutStr-html.
define variable v-report-name-html as character no-undo .
define variable v-report-name-html-list as character no-undo .
define variable v-report-name-html-result as character no-undo .
define variable v-report-result         as logical   no-undo .

{ str/getctxtp.i get p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).

  v-report-name-html = session:temp-directory + {&DF_Name} + string(g#report-num) + ".html". /*формирование имя файла*/
  
/*run get-quest-print in p-mainmenu-handle (*/
/*    output g#quest-print                  */
/*).                                        */
/*временная таблица для передачи параметров*/
{ gbl/paramls.i         }

find first t-doc no-lock
     where recid( t-doc ) = rec_id
.
{ gbl/hostcode.i
    t-doc.obj-type
    t-doc.obj-code
    v-host-code
}
/*Чтение параметров печати форм*/
run torgconf-read in this-procedure (
      input "torg15"
    , input v-host-code
    , input t-doc.obj-type
    , input t-doc.obj-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров печати формы."
    skip "Форма будет напечатана с параметрами по умолчанию."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box error.
end.

if v-torgconf-outnum = yes
then do:
    assign
        tdoc-code = fill( " ", 10 )
    .
end.
else do:
    assign
        tdoc-code = t-doc.doc-code
    .
end.
if v-torgconf-outdate = yes
then do:
    assign
        v-doc-date-string = fill( " ", 10 )
    .
end.
else do:
    assign
        v-doc-date-string = ( if t-doc.status_ <> {&fact}
                            then string( t-doc.doc-date,  "99/99/9999" )
                            else string( t-doc.fact-date, "99/99/9999" )
                            )
    .
end.
find first OurObject no-lock
     where OurObject.obj-type = t-doc.obj-type
       and OurObject.obj-code = t-doc.obj-code
no-error.

{ gbl/basecode.i
  t-doc.host-code
  v-base-code
}

/*валюта*/
find first currency no-lock
     where currency.curr-code = v-base-code
no-error.

assign val-str = ( if PrintRubl then "{&abbr_rublyah}" else (if available currency then currency.curr-abbr else "?") ) .


find first clients no-lock
     where clients.obj-type = {&cmp}
       and clients.obj-code = t-doc.host-code
.
/*доп параметры для клиентов*/
{ rep/r-cliprp.i }

find first b-trn-doc no-lock
     where b-trn-doc.doc-code = t-doc.doc-code no-error.
        if available b-trn-doc then do: 
            assign 
            date-in = b-trn-doc.fact-date
            v-reason-code = b-trn-doc.reason-code .
        
        find first trn-reason where  trn-reason.reason-code = v-reason-code no-error.
        if AVAILABLE trn-reason then
        v-reason = trn-reason.reason-name . 

       end.
       
 /*Печать шапки для листа 1*/
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
        substitute(
          '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   .class1 ~{
                       border-collapse: collapse;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="ТОРГ_15_1" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:20px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:100px"></td>
                        <td style="width:20px"></td>
                        <td style="width:50px"></td>
                        <td style="width:20px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:30px"></td>
                        <td style="width:50px"></td>
                        <td style="width:70px"></td>
                      </tr>
                    <tr>
                      <td colspan="16"></td>
                      <td colspan="5">Унифицированная форма № ТОРГ-15</td>
                    </tr>
                    <tr>
                      <td colspan="16"></td>
                      <td colspan="5">Утверждена постановлением Госкомстата</td>
                    </tr>
                    <tr>
                      <td colspan="16"></td>
                      <td colspan="5">России от 25.12.98 №132</td>
                    </tr>                    
                    <tr>
                      <td colspan="18"></td>
                      <td colspan="3" style="border: 1px solid black; text-align: center;">Код</td>
                    </tr>
                    <tr>
                      <td colspan="16"></td>
                      <td colspan="2" style="text-align: right;">Форма по ОКУД</td>
                      <td colspan="3" style="border: 1px solid black; text-align: center;">0330215</td>
                    </tr>   
                    <tr>
                      <td colspan="16">&1</td>
                      <td colspan="2" style="text-align: right;">по ОКПО</td>
                      <td colspan="3" style="border: 1px solid black; text-align: center; max-height: 14px;">&2</td>
                    </tr>  
                    <tr>
                      <td colspan="16" style="font-size:8px; border-top: 1px solid black; text-align: center; height: 10px;">(организация, адрес)</td>
                      <td colspan="2" style="text-align: right;"></td>
                      <td rowspan="2" colspan="3" style="border: 1px solid black;"></td>
                    </tr>  
                    <tr>
                      <td colspan="18" >&3</td>
                    </tr>  
                    <tr>
                      <td colspan="18" style="font-size:8px; border-top: 1px solid black; text-align: center; height: 10px;">(структурное подразделение)</td>
                      <td rowspan="2" colspan="3" style="border: 1px solid black;"></td>
                    </tr> 
                    <tr>
                      <td>Поставщик</td>
                      <td colspan="15"></td>
                      <td colspan="2" style="text-align: right; border-bottom: 1px solid black;">по ОКПО</td>
                    </tr>  
                    <tr>
                      <td></td>
                      <td colspan="17" style="font-size:8px; border-top: 1px solid black; text-align: center; height: 10px;">(наименование, адрес, номер телефона, банковские реквизиты)</td>
                      <td rowspan="2" colspan="3" style="border: 1px solid black;"></td>
                    </tr>
                    <tr>
                      <td colspan="14"></td>
                      <td colspan="4" style="text-align: right;">Вид деятельности по ОКДП</td>
                    </tr> 
                    <tr>
                      <td colspan="10"></td>
                      <td colspan="5"></td>
                      <td colspan="3" style="text-align: right;">Вид операции</td>
                      <td colspan="3" style="border: 1px solid black; text-align: center; height: 20px;">списание</td>
                    </tr> 
                    <tr>
                      <td colspan="9"></td>
                      <td colspan="2" style="border-top: 1px solid black; border-right: 1px solid black; border-left: 1px solid black; text-align: center;">Номер</td>
                      <td style="border-top: 1px solid black; border-right: 1px solid black; text-align: center;">Дата</td>
                      <td colspan="4"></td>                      
                      <td colspan="5" style="text-align: center;">УТВЕРЖДАЮ</td>
                    </tr> 
                    <tr>
                      <td colspan="9"></td>
                      <td colspan="2" style="border-right: 1px solid black; border-left: 1px solid black; text-align: center;">документа</td>
                      <td style="border-right: 1px solid black; text-align: center;">составления</td>
                      <td colspan="4"></td>                      
                      <td colspan="5" style="text-align: center;">Руководитель</td>
                    </tr> 
                    <tr>
                      <td rowspan="2" colspan="7" style="text-align: center; font-weight: bold;"></td>
                      <td rowspan="2" colspan="2" style="text-align: center; font-weight: bold;">АКТ </td>
                      <td rowspan="2" colspan="2" style="text-align: center; border: 2px solid black;">&4</td>
                      <td rowspan="2" style="border: 2px solid black; text-align: center;">&5</td>
                      <td colspan="4" ></td>                      
                      <td colspan="5" style="text-align: center;">___________________________</td>
                    </tr> 
                    <tr>
                      <td colspan="4"></td>                      
                      <td colspan="5" style="font-size:8px; text-align: center;">(должность)</td>
                    </tr>
                    <tr>
                      <td colspan="5"></td>
                      <td colspan="8" style="text-align: center; font-weight:bold;">о порче, бое, ломе товарно-материальных ценностей</td>
                      <td colspan="3"></td>
                      <td colspan="2"  style="border-bottom: 1px solid black; text-align: center;"></td>
                      <td></td>
                      <td colspan="2"  style="border-bottom: 1px solid black; text-align: center;"></td>
                    </tr>                     
                    <tr>
                      <td colspan="5"></td>
                      <td colspan="8"></td>
                      <td colspan="3"></td>
                      <td colspan="2" style="font-size:8px; text-align: center;">(подпись)</td>
                      <td></td>
                      <td colspan="2" style="font-size:8px; text-align: center;">(расшифровка подписи)</td>
                    </tr>                     
                    <tr>
                      <td colspan="16"></td>
                      <td></td>
                      <td  style="text-align: center;">" ___ "</td>
                      <td colspan="2"  style="text-align: center;">______________</td>
                      <td>______г.</td>
                    </tr>   
                    <tr>
                        <td colspan="21" style="height: 5px;"></td>
                    </tr>
                    <tr>
                      <td colspan="12">Комиссия произвела осмотр товарно-материальных ценностей, подлежащих уценке (списанию) вследствие</td>
                      <td colspan="6"  style="border-bottom: 1px solid black; text-align: center;">&6</td>
                      <td></td>
                      <td>Код</td>
                      <td style="border: 2px solid black;"></td>
                    </tr>
                    <tr>
                        <td colspan="12"></td>
                        <td colspan="5" style="font-size:8px; text-align: center;">(наименование причины)</td>
                        <td colspan="3"></td>
                    </tr>                          
                    <tr>
                        <td colspan="11">и установила:</td>
                        <td colspan="6" style="font-size:7px;"></td>
                        <td colspan="3"></td>
                    </tr> 
                    <tr>
                        <td colspan="21" style="height: 5px;"></td>
                    </tr>
                    </thead>'
      ,
        string( "{&abbr_inn_allshift} " + t-inn + " " + caps( clients.obj-name ) + " (" + string(clients.obj-code) + ")" + t-addres + t-phone),
        t-okpo,
        string( caps( OurObject.obj-name ) + " (" + string(OurObject.obj-code) + ")" ) ,
        string( tdoc-code , "X(16)"),
        v-doc-date-string,
        v-reason /*причина списания*/
      ).
    output stream OutStr-html close.        


/*шапка таблицы HTML*/
         
                output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
                put stream OutStr-html unformatted
                  substitute (
                  '<tbody> <!-- Здесь начинается таблица отчета -->
                            <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                                <th colspan="3" style="text-align: center;">Товарно-материальные ценности</th>
                                <th colspan="2" style="text-align: center;">Единица измерения</th>
                                <th rowspan="2" style="text-align: center;">Артикул товара</th>
                                <th rowspan="2" style="text-align: center;">Сорт (категория)</th>
                                <th rowspan="2" colspan="2" style="text-align: center;">Количество (масса)</th>
                                <th rowspan="2" colspan="2" style="text-align: center;">Учетная цена, руб. коп.</th>
                                <th rowspan="2" style="text-align: center;">Сумма, руб. коп.</th>
                                <th colspan="6" style="text-align: center;">Подлежит уценке</th>
                                <th rowspan="2" style="text-align: center;">Процент скидки</th>
                                <th rowspan="2" colspan="2" style="text-align: center;">Характеристика дефекта</th>
                            </tr>
                            <tr>
                                <th colspan="2" style="text-align: center;">наименование, характеристика</th>
                                <th style="text-align: center;">код</th>
                                <th style="text-align: center;">наименование</th>
                                <th style="text-align: center;">код по ОКЕИ</th>
                                <th colspan="2" style="text-align: center;">количество (масса)</th>
                                <th colspan="2" style="text-align: center;">новая цена, руб. коп.</th>
                                <th style="text-align: center;">стоимость по новой цене, руб. коп.</th>
                                <th style="text-align: center;">сумма уценки, руб. коп.</th>
                            </tr>
                            <tr>
                                <th colspan="2" style="text-align: center;">1</th>
                                <th style="text-align: center; border-bottom: 2px solid black;">2</th>
                                <th style="text-align: center;">3</th>
                                <th style="text-align: center; border-bottom: 2px solid black;">4</th>
                                <th style="text-align: center; border-bottom: 2px solid black;">5</th>
                                <th style="text-align: center; border-bottom: 2px solid black;">6</th>
                                <th colspan="2" style="text-align: center; border-bottom: 2px solid black;">7</th>
                                <th colspan="2" style="text-align: center; border-bottom: 2px solid black;">8</th>
                                <th style="text-align: center; border-bottom: 2px solid black;">9</th>
                                <th colspan="2" style="text-align: center; border-bottom: 2px solid black;">10</th>
                                <th colspan="2" style="text-align: center; border-bottom: 2px solid black;">11</th>
                                <th style="text-align: center; border-bottom: 2px solid black;">12</th>
                                <th style="text-align: center; border-bottom: 2px solid black;">13</th>
                                <th style="text-align: center;">14</th>
                                <th colspan="2" style="text-align: center;">15</th>
                            </tr>
                            '
                  , chr(123), chr(125)
                  ).
                  
    assign
        sumtqnty = 0
        sumstoim = 0 
    .



for  each doc-line no-lock
    where doc-line.doc-code = t-doc.doc-code
break by doc-line.artic
:
    find first goods no-lock
         where goods.prod-type = doc-line.prod-type
           and goods.prod-code = doc-line.prod-code
           and goods.artic = doc-line.artic
    .
                    run get-okei in this-procedure (
                    input goods.unit-base
                    , output v-okei
                ).
    find first gds-prt no-lock
         where gds-prt.upper-code = goods.prt-root
    .
    assign
        rootnode_code = gds-prt.node-code
    .
    if CostPrice
    then do:
        { str/in-vatp.i calc doc-line. t-doc. g }
        assign
            price = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
            price-Vat = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
        .
        if price-Vat = ? then assign price-Vat = 0 .
        if no-vat then do:
            assign
                price = price - price-Vat
            .
        end.
    end.

    if ( ( gds-prt.node-name <> {&empty-scale} ) and v-cntxp-doc-prt = yes )
    then do:     /* Т.е. не пустая шкала */
            if PrintScale
            then do:
                if no-vat then do:
                        put stream OutStr-html unformatted
                          substitute (
                          '<tr>
                                <td colspan="2" style="text-align: center;">&1</td>
                                <td style="text-align: center; border-left: 2px solid black; border-right: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center; border-left: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center; border-right: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                           </tr>    
                                    '
                          ,goods.gds-name
                          ).                    

                end.
                else do:
                        put stream OutStr-html unformatted
                          substitute (
                          '<tr>
                                <td colspan="2" style="text-align: center;">&1</td>
                                <td style="text-align: center; border-left: 2px solid black; border-right: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center; border-left: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center; border-right: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                           </tr>    
                                    '
                          ,
                          goods.gds-name
                          ).      
                                              
                end.
            end.
            { gbl/working.i }
            for each gds-dtl no-lock
               where gds-dtl.prod-type = doc-line.prod-type
                 and gds-dtl.prod-code = doc-line.prod-code
                 and gds-dtl.artic = doc-line.artic
                 and gds-dtl.doc-code = doc-line.doc-code
            break by gds-dtl.artic
            :
                find gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock.

                if not CostPrice
                then do:
                    { str/out-vatp.i calc-gds-dtl doc-line. t-doc. gds-dtl. }
                    assign
                        price = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
                        price-Vat = ( if PrintRubl then vat-rubl-sale else vat-base-sale )
                    .
                    if first (gds-dtl.artic)
                    then do:
                        assign
                            v-prices-are-different  = no
                            v-old-price             = price
/*                            v-old-price-Vat         = price-Vat*/
                        .
                    end.
                    else do:
                        if v-prices-are-different  = no
                            and price <> v-old-price
                        then do:
                            assign
                                v-prices-are-different = yes
                            .
                        end.
                        else do:
                            assign
                                v-old-price             = price
/*                                v-old-price-Vat         = price-Vat*/
                            .
                        end.
                    end.
                    if no-vat then do:
                        assign
                            price = price - price-Vat
                        .
                    end.

                end.   /* if not CostPrice */

                assign
                    prt-tqnty =  gds-dtl.fact-qnty
                    prt-stoim = price * prt-tqnty
/*                    prt-stoim-Vat = price-Vat * prt-tqnty*/
                .
                accumulate
                    prt-tqnty (total)
                    prt-stoim ( total )
/*                    prt-stoim-Vat ( total )*/
                .
                if PrintScale = yes
                then do:
                    find first bar-code no-lock
                         where bar-code.gds-code = goods.gds-code
                           and bar-code.unit-cli = goods.unit-base
                           and bar-code.node-code = gds-dtl.prt-code
                           and bar-code.part-code = ""
                           and bar-code.in-code = ""
                    .
                    assign
                        PrtName = ""
                    .
                    do while available gds-prt:
                        if available gds-prt
                        then do:
                            assign
                                PrtName = "\" + string( gds-prt.node-name, "x(10)" ) + PrtName
                                PrtNameXL = "\" + gds-prt.node-name + PrtNameXl
                            .
                        end.
                        assign
                            Node_Code = gds-prt.upper-code
                        .
                        find first gds-prt no-lock
                                where gds-prt.node-code = Node_Code
                                and gds-prt.root <> yes
                        no-error.
                    end.
                    if no-vat then do:
                        put stream OutStr-html unformatted
                          substitute (
                          '<tr>
                                <td colspan="2" style="text-align: center;">&1</td>
                                <td style="text-align: center; border-left: 2px solid black; border-right: 2px solid black;">&2</td>
                                <td style="text-align: center;">&3</td>
                                <td style="text-align: center; border-left: 2px solid black;">&4</td>
                                <td style="text-align: center;">&5</td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;">&6</td>
                                <td colspan="2" style="text-align: center;">&7</td>
                                <td style="text-align: center;">&8</td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center; border-right: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                           </tr>    
                                    '
                          ,
                          goods.gds-name,
                          string( bar-code.b-code ),
                          goods.unit-base,
                          v-okei, /*код по ОКЕИ*/ 
                          goods.artic,
                          prt-tqnty,
                          string(price,"->>>>>>>>>>>>>>>>9.99"),
                          string(prt-stoim,"->>>>>>>>>>>>>>>>9.99")
                          ).                              

                    end.
                    else do:
                        put stream OutStr-html unformatted
                          substitute (
                          '<tr>
                                <td colspan="2" style="text-align: center;">&1</td>
                                <td style="text-align: center; border-left: 2px solid black; border-right: 2px solid black;">&2</td>
                                <td style="text-align: center;">&3</td>
                                <td style="text-align: center; border-left: 2px solid black;">&4</td>
                                <td style="text-align: center;">&5</td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center;">&6</td>
                                <td colspan="2" style="text-align: center;">&7</td>
                                <td colspan="2" style="text-align: center;">&8</td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td style="text-align: center; border-right: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                           </tr>    
                                    '
                          ,
                          goods.gds-name,
                          string( bar-code.b-code ),
                          goods.unit-base,
                          v-okei, /*код по ОКЕИ*/ 
                          goods.artic,
                          prt-tqnty,
                          string(price,"->>>>>>>>>>>>>>>>9.99"),
                          string(prt-stoim,"->>>>>>>>>>>>>>>>9.99")
                          ).    


                    end.
                end.        /* if PrintScale = yes */
            end.        /*for each gds-dtl ...*/

            assign
                tqnty = ( accum total prt-tqnty )
                stoim = ( accum total prt-stoim )
/*                stoim-Vat = ( accum total prt-stoim-Vat )*/
            .

            if not PrintScale
            then do:
                    find first bar-code no-lock
                         where bar-code.gds-code = goods.gds-code
                           and bar-code.unit-cli = goods.unit-base
                           and bar-code.node-code = rootnode_code
                           and bar-code.part-code = ""
                           and bar-code.in-code = ""
                    .
                    if no-vat then do:
                        put stream OutStr-html unformatted
                          substitute (
                          '<tr>
                                <td colspan="2" style="text-align: center;">&1</td>
                                <td style="text-align: center; border-left: 2px solid black; border-right: 2px solid black;">&2</td>
                                <td style="text-align: center;">&3</td>
                                <td style="text-align: center; border-left: 2px solid black;">&4</td>
                                <td style="text-align: center;">&5</td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;">&6</td>
                                <td colspan="2" style="text-align: center;">&7</td>
                                <td style="text-align: center;">&8</td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center; border-right: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                           </tr>    
                                    '
                          ,
                          goods.gds-name,
                          string( bar-code.b-code ),
                          goods.unit-base,
                          v-okei, /*код по ОКЕИ*/ 
                          goods.artic,
                          tqnty,
                          string(price,"->>>>>>>>>>>>>>>>9.99"),
                          string(stoim,"->>>>>>>>>>>>>>>>9.99")
                          ).    

                    end.
                    else do:
                         put stream OutStr-html unformatted
                          substitute (
                          '<tr>
                                <td colspan="2" style="text-align: center;">&1</td>
                                <td style="text-align: center; border-left: 2px solid black; border-right: 2px solid black;">&2</td>
                                <td style="text-align: center;">&3</td>
                                <td style="text-align: center; border-left: 2px solid black;">&4</td>
                                <td style="text-align: center;">&5</td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;">&6</td>
                                <td colspan="2" style="text-align: center;">&7</td>
                                <td style="text-align: center;">&8</td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center; border-right: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                           </tr>    
                                    '
                          ,
                          goods.gds-name,
                          string( bar-code.b-code ),
                          goods.unit-base,
                          v-okei, /*код по ОКЕИ*/ 
                          goods.artic,
                          tqnty,
                          string(price,"->>>>>>>>>>>>>>>>9.99"),
                          string(stoim,"->>>>>>>>>>>>>>>>9.99")
                          ).    
                          

                    end.
            end.        /* if not PrintScale */
            assign
    sumtqnty = sumtqnty + tqnty 
    sumstoim = sumstoim + stoim 
    .
    end.            /* не пустая шкала */
    else do:    /* пустая шкала */

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

            if not CostPrice
            then do:
                    { str/out-vatp.i calc-gds-dtl doc-line. t-doc. gds-dtl. }
                    assign
                        price = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
                        price-Vat = ( if PrintRubl then vat-rubl-sale else vat-base-sale )
                    .
                    if no-vat then do:
                        assign
                            price = price - price-Vat
                        .
                    end.
            end.

            assign
                tqnty = gds-dtl.fact-qnty
                unit-str = goods.unit-base
                stoim = price * tqnty
/*                stoim-Vat = price-Vat * tqnty*/
            .

            if no-vat then do:
                        put stream OutStr-html unformatted
                          substitute (
                          '<tr>
                                <td colspan="2" style="text-align: center;">&1</td>
                                <td style="text-align: center; vborder-left: 2px solid black; border-right: 2px solid black;">&2</td>
                                <td style="text-align: center;">&3</td>
                                <td style="text-align: center; border-left: 2px;">&4</td>
                                <td style="text-align: center;">&5</td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;">&6</td>
                                <td colspan="2" style="text-align: center;">&7</td>
                                <td style="text-align: center;">&8</td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center; border-right: 2px;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                           </tr>
                                    '
                          ,
                          goods.gds-name,
                          string( bar-code.b-code ),
                          goods.unit-base,
                          v-okei, /*код по ОКЕИ*/
                          goods.artic,
                          tqnty,
                          string(price,"->>>>>>>>>>>>>>>>9.99"),
                          string(stoim,"->>>>>>>>>>>>>>>>9.99")
                          ).


            end.
            else do:
                         put stream OutStr-html unformatted
                          substitute (
                          '<tr>
                                <td colspan="2" style="text-align: center;">&1</td>
                                <td style="text-align: center;">&2</td>
                                <td style="text-align: center;">&3</td>
                                <td style="text-align: center; border-left: 2px solid black;">&4</td>
                                <td style="text-align: center;">&5</td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;">&6</td>
                                <td colspan="2" style="text-align: center;">&7</td>
                                <td style="text-align: center;">&8</td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center; border-right: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                           </tr>'
                          ,
                          goods.gds-name,
                          string( bar-code.b-code ),
                          goods.unit-base,
                          string(v-okei), /*код по ОКЕИ*/
                          goods.artic,
                          string(tqnty),
                          string(price,"->>>>>>>>>>>>>>>>9.99"),
                          string(stoim,"->>>>>>>>>>>>>>>>9.99")
                          ).

            end.
    assign
    sumtqnty = sumtqnty + tqnty 
    sumstoim = sumstoim + stoim 
    .            
    end.
/*                     */
/*    accumulate       */
/*        tqnty (total)*/
/*        stoim (total)*/
/*        .            */

end.        /*for  each doc-line ...*/



if no-vat then do:


                        put stream OutStr-html unformatted
                          substitute (
                          '<tr>
                                <td colspan="2" style="text-align: center; border: none;"></td>
                                <td style="text-align: center; border-bottom: none; border-left: none; border-right: none; border-top: 2px solid black;"></td>
                                <td style="text-align: center; border: none;"></td>
                                <td style="text-align: center; border-bottom: none; border-left: none; border-right: none; border-top: 2px solid black;"></td>
                                <td style="text-align: center; border-bottom: none; border-left: none; border-right: none; border-top: 2px solid black;"></td>
                                <td style="text-align: right; border-bottom: none; border-left: none; border-right: none; border-top: 2px solid black;">Итого:</td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;">&1</td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;">Х</td>
                                <td style="text-align: center; border-top: 2px solid black;">&2</td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;">Х</td>
                                <td style="text-align: center; border-top: 2px solid black;"></td>
                                <td style="text-align: center; border-top: 2px solid black;"></td>
                                <td colspan="3" style="text-align: center; border: none;"></td>
                           </tr>
                                    '
                          ,
                          sumtqnty,
                          string(sumstoim,"->>>>>>>>>>>>>>>>9.99")
                          ).

 end.
 else do:
                        put stream OutStr-html unformatted
                          substitute (
                          '<tr>
                                <td colspan="2" style="text-align: center; border: none;"></td>
                                <td style="text-align: center; border-bottom: none; border-left: none; border-right: none; border-top: 2px solid black;"></td>
                                <td style="text-align: center; border: none;"></td>
                                <td style="text-align: center; border-bottom: none; border-left: none; border-right: none; border-top: 2px solid black;"></td>
                                <td style="text-align: center; border-bottom: none; border-left: none; border-right: none; border-top: 2px solid black;"></td>
                                <td style="text-align: right; border-bottom: none; border-left: none; border-right: none; border-top: 2px solid black;">Итого:</td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;">&1</td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;">Х</td>
                                <td style="text-align: center; border-top: 2px solid black;">&2</td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;">Х</td>
                                <td style="text-align: center; border-top: 2px solid black;"></td>
                                <td style="text-align: center; border-top: 2px solid black;"></td>
                                <td colspan="3" style="text-align: center; border: none;"></td>
                            </tr>
                                    '
                          ,
                          sumtqnty,
                          string(sumstoim,"->>>>>>>>>>>>>>>>9.99")
                          ).

 end.
/*сумма прописью*/
 run rep/wp-rub.p ( sumstoim, output PropisStoim, output abbr).
 /*подвал первой страницы*/
                 put stream OutStr-html unformatted
                  substitute (
                  '</tbody>
                  <tfoot> <!-- Здесь начинается таблица отчета -->
                            <tr>
                                <td colspan="21" style="height: 5px;"></td>
                            </tr>
                            <tr>
                                <td colspan="3">Причины порчи, боя, лома</td>
                                <td colspan="15" style="text-align: center; border-bottom: 1px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center;">Код</td>
                                <td style="text-align: center; border: 2px solid black;"></td>
                            </tr>
                            <tr>
                                <td colspan="3"></td>
                                <td colspan="15" style="text-align: center; font-size: 8px;">(наименование)</td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                                <td style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="2" style="text-align: left;">Виновными в</td>
                                <td colspan="3" style="text-align: center; border-bottom: 1px solid black;">порче, бое, ломе</td>
                                <td colspan="2" style="text-align: right;">являются</td>
                                <td colspan="14" style="text-align: center; border-bottom: 1px solid black;"></td>
                            </tr>
                            <tr>
                                <td colspan="2" style="text-align: left;"></td>
                                <td colspan="3" style="text-align: center; font-size: 8px;">(ненужное зачеркнуть)</td>
                                <td colspan="2" style="text-align: right;"></td>
                                <td colspan="14" style="text-align: center; font-size: 8px;">(должность, фамилия, и.о.)</td>
                            </tr>
                            <tr>
                                <td colspan="21" style="text-align: right; border-bottom: 1px solid black; height: 20px;"></td>
                            </tr>
                            <tr><td colspan="21"></td></tr>
                       </tfoot>
                     </table>
                            '
                  , chr(123), chr(125)
                  ).

/*---END----------- Списание по товарам документа ---------------------*/

/*Вторая страница*/
        put stream OutStr-html unformatted
        substitute(
          ' <table orientation="landscape" name="ТОРГ_15_2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:20px"></td>
                        <td style="width:40px"></td>
                        <td style="width:50px"></td>
                        <td style="width:40px"></td>
                        <td style="width:50px"></td>
                        <td style="width:40px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:30px"></td>
                        <td style="width:30px"></td>
                        <td style="width:70px"></td>
                    </tr>
                    <tr>
                        <td colspan="20" style="height: 5px;"></td>
                    </tr>
                    <tr>
                      <td colspan="15"></td>
                      <td colspan="5" style="text-align: right;">Оборотная сторона формы № ТОРГ-15</td>
                    </tr>
                    <tr>
                      <td colspan="3">Оприходовать утиль (лом):</td>
                      <td colspan="17"></td>
                    </tr>
                    </thead>
                    <tbody> <!-- Здесь начинается таблица отчета -->
                            <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                                <th colspan="6" style="text-align: center;">Утиль (лом)</th>
                                <th colspan="3" style="text-align: center;">Единица измерения</th>
                                <th rowspan="2" colspan="2" style="text-align: center;">Количество (масса)</th>
                                <th rowspan="2" colspan="2" style="text-align: center;">Цена руб. коп.</th>
                                <th rowspan="2" colspan="3" style="text-align: center;">Сумма, руб. коп.</th>
                                <th colspan="4" style="text-align: center;">Приходный ордер</th>
                            </tr>
                            <tr>
                                <th colspan="4" style="text-align: center;">наименование</th>
                                <th colspan="2" style="text-align: center;">код (номенклатурный номер)</th>
                                <th style="text-align: center;">наименование</th>
                                <th colspan="2" style="text-align: center;">код по ОКЕИ</th>
                                <th colspan="2" style="text-align: center;">номер</th>
                                <th colspan="2" style="text-align: center;">дата</th>
                            </tr>
                            <tr>
                                <th colspan="4" style="text-align: center;">1</th>
                                <th colspan="2" style="text-align: center;">2</th>
                                <th style="text-align: center;">3</th>
                                <th colspan="2" style="text-align: center;">4</th>
                                <th colspan="2" style="text-align: center;">5</th>
                                <th colspan="2" style="text-align: center;">6</th>
                                <th colspan="3" style="text-align: center;">7</th>
                                <th colspan="2" style="text-align: center;">8</th>
                                <th colspan="2" style="text-align: center;">9</th>
                            </tr>
                            <tr>
                                <td colspan="4" style="text-align: center; height: 20px;"></td>
                                <td colspan="2" style="text-align: center; border-left: 2px solid black; border-right: 2px solid black; border-top: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center; border-left: 2px solid black; border-top: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;"></td>
                                <td colspan="3" style="text-align: center; border-top: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center; border-top: 2px solid black;  border-right: 2px solid black;"></td>
                            </tr>
                            <tr>
                                <td colspan="4" style="text-align: center; height: 20px;"></td>
                                <td colspan="2" style="text-align: center; border-left: 2px solid black; border-right: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center; border-left: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="3" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center; border-right: 2px solid black;"></td>
                            </tr>
                            <tr>
                                <td colspan="4" style="text-align: center; height: 20px;"></td>
                                <td colspan="2" style="text-align: center; border-left: 2px solid black; border-right: 2px solid black; border-bottom: 2px solid black;"></td>
                                <td style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center; border-left: 2px solid black; border-bottom: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center; border-bottom: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center; border-bottom: 2px solid black;"></td>
                                <td colspan="3" style="text-align: center; border-bottom: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center; border-bottom: 2px solid black;"></td>
                                <td colspan="2" style="text-align: center; border-right: 2px solid black; border-bottom: 2px solid black;"></td>
                            </tr>
                            <tr>
                                <td colspan="9" style="text-align: right; border: none;">Итого</td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="2" style="text-align: center;">Х</td>
                                <td colspan="3" style="text-align: center;"></td>
                                <td colspan="4" style="text-align: center; border: none;"></td>
                            </tr>
                         </tbody>'
                         , chr(123), chr(125)
                         ).

                         put stream OutStr-html unformatted
                         substitute(
                         '<tfoot>
                            <tr>
                                  <td colspan="20">Все члены комиссии предупреждены об ответственности за подписание акта, содержащего данные, не соответствующие действительности.</td>
                            </tr>
                            <tr>
                                <td colspan="2">Председатель комиссии</td>
                                <td colspan="3" style="border-bottom: 1px solid black;"></td>
                                <td></td>
                                <td colspan="2" style="border-bottom: 1px solid black;"></td>
                                <td></td>
                                <td colspan="4" style="border-bottom: 1px solid black;"></td>
                                <td colspan="7" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="2"></td>
                                <td colspan="3" style="font-size: 8px; text-align: center;">(должность)</td>
                                <td></td>
                                <td colspan="2" style="font-size: 8px; text-align: center;">(подпись)</td>
                                <td></td>
                                <td colspan="4" style="font-size: 8px; text-align: center;">(расшифровка подписи)</td>
                                <td colspan="7" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="2">Члены комиссии:</td>
                                <td colspan="3" style="border-bottom: 1px solid black;"></td>
                                <td></td>
                                <td colspan="2" style="border-bottom: 1px solid black;"></td>
                                <td></td>
                                <td colspan="4" style="border-bottom: 1px solid black;"></td>
                                <td colspan="7" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="2"></td>
                                <td colspan="3" style="font-size: 8px; text-align: center;">(должность)</td>
                                <td></td>
                                <td colspan="2" style="font-size: 8px; text-align: center;">(подпись)</td>
                                <td></td>
                                <td colspan="4" style="font-size: 8px; text-align: center;">(расшифровка подписи)</td>
                                <td colspan="7" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="2"></td>
                                <td colspan="3" style="border-bottom: 1px solid black;height: 20px;"></td>
                                <td></td>
                                <td colspan="2" style="border-bottom: 1px solid black;"></td>
                                <td></td>
                                <td colspan="4" style="border-bottom: 1px solid black;"></td>
                                <td colspan="7" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="2"></td>
                                <td colspan="3" style="font-size: 8px; text-align: center;">(должность)</td>
                                <td></td>
                                <td colspan="2" style="font-size: 8px; text-align: center;">(подпись)</td>
                                <td></td>
                                <td colspan="4" style="font-size: 8px; text-align: center;">(расшифровка подписи)</td>
                                <td colspan="7" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="2"></td>
                                <td colspan="3" style="border-bottom: 1px solid black; height: 20px;"></td>
                                <td></td>
                                <td colspan="2" style="border-bottom: 1px solid black;"></td>
                                <td></td>
                                <td colspan="4" style="border-bottom: 1px solid black;"></td>
                                <td colspan="7" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="2"></td>
                                <td colspan="3" style="font-size: 8px; text-align: center;">(должность)</td>
                                <td></td>
                                <td colspan="2" style="font-size: 8px; text-align: center;">(подпись)</td>
                                <td></td>
                                <td colspan="4" style="font-size: 8px; text-align: center;">(расшифровка подписи)</td>
                                <td colspan="7" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="20">Распоряжение руководителя организации:</td>
                            </tr>
                            <tr>
                                <td colspan="4">Указанные выше материалы (товары)</td>
                                <td colspan="16" style="text-align: center; border-bottom: 1px solid black;">списать</td>
                            </tr>
                            <tr>
                                <td colspan="2">Стоимость</td>
                                <td colspan="3" style="text-align: center; border-bottom: 1px solid black;">порчи, боя, лома</td>
                                <td colspan="2" style="text-align: center;">отнести на счет</td>
                                <td colspan="13" style="text-align: center; border-bottom: 1px solid black;"></td>
                            </tr>
                            <tr>
                                <td colspan="2"></td>
                                <td colspan="3" style="text-align: center; font-size: 8px;">(ненужное зачеркнуть)</td>
                                <td colspan="2" style="text-align: center;"></td>
                                <td colspan="13" style="text-align: center; font-size: 8px;">(указать источник(себестоимость, прибыль, материально ответственное лицо))</td>
                            </tr>
                            <tr>
                                <td colspan="2">в сумме</td>
                                <td colspan="16" style="text-align: center; border-bottom: 1px solid black;"></td>
                                <td colspan="2">руб. ______ коп.</td>
                            </tr>
                            <tr>
                                <td colspan="2"></td>
                                <td colspan="16" style="text-align: center; font-size: 8px;">(прописью)</td>
                                <td colspan="2" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="4">Утиль (лом) оприходовать в сумме</td>
                                <td colspan="14" style="text-align: center; border-bottom: 1px solid black;"></td>
                                <td colspan="2">руб. ______ коп.</td>
                            </tr>
                            <tr>
                                <td colspan="4"></td>
                                <td colspan="14" style="text-align: center; font-size: 8px;">(прописью)</td>
                                <td colspan="2" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="6">Все негодные товарно-материальные ценности в сумме</td>
                                <td colspan="14" style="text-align: center; border-bottom: 1px solid black;">&1</td>
                            </tr>
                            <tr>
                                <td colspan="6"></td>
                                <td colspan="14" style="text-align: center; font-size: 8px;">(прописью)</td>
                            </tr>
                            <tr>
                                <td colspan="5">уничтожены в присутствии комиссии</td>
                                <td colspan="2" style="text-align: center; border-bottom: 1px solid black;"></td>
                                <td colspan="6" style="text-align: center;">или вывезены на свалку по накладной №</td>
                                <td colspan="2" style="text-align: center;">__________</td>
                                <td colspan="5" >____________ от " ___ " __________   _____г.</td>
                            </tr>
                            <tr>
                                <td></td>
                                <td colspan="2" >Расчет произвел</td>
                                <td colspan="2" style="border-bottom: 1px solid black;"></td>
                                <td></td>
                                <td colspan="2" style="border-bottom: 1px solid black;"></td>
                                <td></td>
                                <td colspan="4" style="border-bottom: 1px solid black;"></td>
                                <td colspan="7" style="text-align: center;"></td>
                            </tr>
                            <tr>
                                <td colspan="3"></td>
                                <td colspan="2" style="font-size: 8px; text-align: center;">(должность)</td>
                                <td></td>
                                <td colspan="2" style="font-size: 8px; text-align: center;">(подпись)</td>
                                <td></td>
                                <td colspan="4" style="font-size: 8px; text-align: center;">(расшифровка подписи)</td>
                                <td colspan="7" style="text-align: center;"></td>
                            </tr>

                         </tfoot>
                         </table>
                         '
      ,  PropisStoim

      ).

      put stream OutStr-html unformatted
        substitute (
        '
        </body>
        </html>
        '
            , chr(123), chr(125)
       ).
output stream OutStr-html close.

    run prn-lib-reportviewer in this-procedure (
        input p-mainmenu-handle
        ,input v-report-name-html
        ,input "" 
        ) no-error.
    if error-status:error then
    do:
        message return-value view-as alert-box.
        return .
    end.

end.

procedure get-okei :
define input parameter p-unit-base as character        no-undo.
define output parameter p-okei as character        no-undo.

    define buffer buf_units         for units.
do
for buf_units
on error undo, return error
:
    find first buf_units no-lock
         where buf_units.unit-name = p-unit-base
    no-error.
    if available buf_units
    and buf_units.OKEI <> 0
    then do:
        assign
            p-okei = string( buf_units.OKEI, ">999":U )
        .
    end.
    else do:
        assign
            p-okei = "":U
        .
    end.
end.
end procedure. /* get-okei */