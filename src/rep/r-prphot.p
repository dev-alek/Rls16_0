block-level on error undo, throw.
/*

$Revision: a35951db4a04, 289, rls $
$Author: EShklyar $
$Date: Tue Dec 01 19:11:22 2015 +0300 $
$Workfile: r-prphot.p $
$Archive: rep/r-prphot.p $

Прайс-лист с фото товаров

Автор: Чернова Светлана Александровна
Дата создания: 05/05/10
Author: Svetlana Chernova
Creation date: 05/05/10

*/
define input parameter p-mainmenu-handle   as handle           no-undo.
define input  parameter p-sort-type   as character no-undo .
define input  parameter p-name        as character no-undo .
define input  parameter p-dostavka    as character no-undo .
define input  parameter p-telefon-1   as character no-undo .
define input  parameter p-telefon-2   as character no-undo .
define input  parameter p-info        as character no-undo .
define input  parameter p-orderinfo  as character no-undo .
define input  parameter p-action     as character no-undo .
define input  parameter p-skidki     as character no-undo .
define input  parameter p-skidki-2   as character no-undo .
define input  parameter p-skidki-3   as character no-undo .
define input  parameter p-skidki-4   as character no-undo .
define input  parameter p-skidki-5   as character no-undo .
define input  parameter p-skidki-6   as character no-undo .
define input  parameter p-skidki-7   as character no-undo .
define input  parameter p-skidki-8   as character no-undo .
define input  parameter p-colsize    as integer   no-undo .
define input  parameter p-hot        as character no-undo .
define input parameter p-minpart as logical no-undo.
define input parameter p-ost          as logical no-undo.
define input parameter p-ref-rec      as character no-undo.

/*

message
p-mainmenu-handle skip
'p-sort-type '  p-sort-type skip
'p-name      '  p-name      skip
'p-dostavka  '  p-dostavka  skip
'p-telefon-1 '  p-telefon-1 skip
'p-telefon-2 '  p-telefon-2 skip
'p-info      '  p-info      skip
'p-orderinfo ' p-orderinfo  skip
'p-action    ' p-action     skip
'p-skidki    ' p-skidki     skip
'p-colsize   ' p-colsize    skip
'p-hot       ' p-hot        skip
.

*/
define variable vss-revision    as character no-undo init "$Revision: a35951db4a04, 289, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:22 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-prphot.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-prphot.p $":U .
define variable vss-description as character no-undo init "Прайс-лист с фото товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ gbl/cur-time.i }
{ gbl/paramls.i  }
{ rep/lkp-font.i }
{ cmp/ini-lib.i  }
{ str/bc-gnrt.i new bc } /* используется в процедуре create-bar-code */
{ str/mplfacor.i }

define temp-table temp-list no-undo
field f-sort   as character
field gds-code as integer
field b-code   as integer
field big-code as character
field artic    as character
field gds-name as character
field price-sale as decimal
field min-part as character
field f-name     as character
index pi
 f-sort

index pi2
 gds-code
.

define stream outstream.

define variable HexStr as character no-undo .
define variable Path-To-Dir-Pictures as character no-undo .
define variable v-dircode1 as character no-undo .
define variable v-dircode2 as character no-undo .
define variable v-b-code as integer   no-undo .
define variable v-ean as character no-undo .
define variable v-proc-name-err as character no-undo initial 'prphot.err'. /* Имя лога */
define variable l-error as logical no-undo. /* Есть ли ошибки */
define variable v-ost-qnty as decimal no-undo.
define variable v-price as decimal no-undo.
define variable v-fact-order as decimal no-undo.
define variable v-date as date no-undo.
define VARIABLE vPar-val as character no-undo .
define VARIABLE vPar-type  as character no-undo .
define VARIABLE v-ph-dir as character no-undo .
define VARIABLE v-path-db-num as character no-undo .
define VARIABLE v-from-db-num as character no-undo .
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable v-value         as character  no-undo.
define variable v-type         as character  no-undo.
define buffer buf_buyer-group for ub.buyer-group.
define buffer buf_price-all for ub.price-all.
define buffer buf_bar-code for ub.bar-code.

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).

{ str/writelog.i def v-proc-name-err } /* Запуск лога для ошибок */
{ rep/f-fdec.i }
{ gbl/getcntxt.i get " " p-mainmenu-handle }
{ ref/gds-attr.i }

      /* Путь к папке изображений c текущей базы*/
      {gbl/conf-rd.i "'ph-dir':u" "'':u" "'':u" 0 "'':u" "'':u" "'':u" NO vPar-val vPar-type no-error}
     
     if vPar-val = "" then vPar-Val = "C:\temp". else vPar-Val = vPar-Val.  
     
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
      
  v-dircode1 = search( 'exe/own-logo.jpg' ) .
  v-dircode2 = search( 'exe/own-tel.jpg' ) .
  
  if search(v-proc-name-err) <> ? then do:
    os-delete value(v-proc-name-err).
  end.
  
  l-error = no.
    
  for each obj-list :
      
      /* Для определения цены по прайсу получим факт-ордер для объекта */
      if p-ref-rec <> "" then do:
      { gbl/curobjdt.i obj-list.obj-type obj-list.obj-code v-date}
      run fact-order-mpl in this-procedure (input v-date,
                                            input obj-list.obj-type,
                                            input obj-list.obj-code,
                                            output v-fact-order) no-error.
      end.
    
    for each gds-list :

      find first ub.gds-obj no-lock where
        ub.gds-obj.gds-code = gds-list.gds-code and
        ub.gds-obj.obj-type = obj-list.obj-type and
        ub.gds-obj.obj-code = obj-list.obj-code no-error .
      if not available ub.gds-obj  then 
      do:
        l-error = yes.
        run writelog in this-procedure (v-proc-name-err, 1, substitute("У товара &1 &2 нет продажной цены",gds-list.artic,gds-list.gds-name)).
        next.
      end.
      if ub.gds-obj.price-sale = 0  then 
      do:
        l-error = yes.
        run writelog in this-procedure (v-proc-name-err, 1, substitute("У товара &1 &2 нулевая цена продажи",gds-list.artic,gds-list.gds-name)).
        next.
      end.

/*определяем путь где лежит картинка*/
      run gds-attr-value in this-procedure (
        input gds-list.gds-code
        ,input "image-list"
        ,output v-value
        ,output v-type) no-error.

      if v-value <> "" then 
      do: /* есть атрибут */
        if v-val-integer = 1 then 
        do:
          Path-To-Dir-Pictures = vPar-val.
        end.
        else 
        do:
          Path-To-Dir-Pictures = vPar-val + "\" + string(gds-list.gds-code).
        end.  
      end. /*if v-value <> "" then*/
      
        
      /* Новые проверки */
        
      /* Определение остатка товара: "Свободно"\"Факт" */
      /*
      if p-gds-ost-type = 1 then v-ost-qnty = ub.gds-obj.free-qnty.
      else v-ost-qnty =  ub.gds-obj.fact-qnty.
      */
      /*
      if v-ost-qnty <= 0 then next.
      */
      /* "Выводить товар с остатком меньше минимальной партии" так что обработаем не выводить */
      if  p-minpart and not (gds-list.qnty-cart > 0) then 
      do:
        l-error = yes.
        run writelog in this-procedure (v-proc-name-err, 1, substitute("У товара &1 &2 не указана минимальная партия",gds-list.artic,gds-list.gds-name)).
        next.       
      end.
      if  p-ost and gds-list.qnty-cart > 0 and ub.gds-obj.free-qnty < gds-list.qnty-cart then 
      do:
        l-error = yes.
        run writelog in this-procedure (v-proc-name-err, 1, substitute("У товара &1 &2 остаток меньше минимальной партии или мин.партия не указана",gds-list.artic,gds-list.gds-name)).
        next.         
      end.
        
      find first temp-list where
        temp-list.gds-code = ub.gds-obj.gds-code no-error .
      if not available temp-list then 
      do:
        
        /* Обработаем цену */
        if p-ref-rec = "" then v-price = ub.gds-obj.price-sale.
        else 
        do:
          /* Определим цену для группы */
          for first buf_buyer-group where recid (buf_buyer-group) = int(p-ref-rec):
                
            run get_price in this-procedure(input ub.gds-obj.obj-type,
              input ub.gds-obj.obj-code,
              input buf_buyer-group.bgr-id,
              input buf_buyer-group.bgr-db-num,
              input ub.gds-obj.gds-code,
              input v-fact-order,
              output v-price).
            if v-price = 0 then  
            do:
              l-error = yes.
              run writelog in this-procedure (v-proc-name-err, 1, substitute("У товара &1 &2 нулевая цена продажи",gds-list.artic,gds-list.gds-name)).
              next.
            end.
          end.
        end.
        
        run gbl/newbase.p
          (input ub.gds-obj.gds-code
          ,input 16
          ,output HexStr
          ).
        create temp-list.

        case p-sort-type :
          when "sort-name" then 
            do:
              temp-list.f-sort          = gds-list.gds-name .
            end.
          when "sort-code" then 
            do:
              temp-list.f-sort          = string(ub.gds-obj.gds-code, "9999999999999999").
            end.
          when "sort-artic" then 
            do:
              temp-list.f-sort          = ub.gds-obj.artic.
            end.
        end case.
        assign
          temp-list.gds-code   = ub.gds-obj.gds-code
          temp-list.artic      = ub.gds-obj.artic
          temp-list.gds-name   = gds-list.gds-name
          temp-list.price-sale = v-price
          temp-list.min-part   = if gds-list.qnty-cart = 0 then  ""  else string(gds-list.qnty-cart)
          temp-list.f-name     = if v-value > '' then  substitute("&1\&2" ,Path-To-Dir-Pictures, entry(1,v-value) ) else ''
          .
          if search(temp-list.f-name) = ? then temp-list.f-name = ''.
        { gbl/gdsbcode.i
               ub.gds-obj.gds-code
               ?
               v-b-code
               }
        temp-list.b-code = v-b-code.

        run gen-bc in this-procedure
          ( input v-b-code
          ,output v-ean
          ).
        temp-list.big-code = v-ean.


        /* Проверить есть ли такой файл на диске */

  
      end.
    end.
  end.
  
  if l-error = yes then /* Если есть ошибки - говорим. */
    message "Не все товары попали в прайс-лист." skip
    substitute("Подробности в файле &1",v-proc-name-err) view-as alert-box warning.
  else os-delete value(v-proc-name-err). /* Если нет - удаляем лог */

   make-excel = true .
   os-delete value( string( session:temp-directory ) +
                              {&df_name} + string( g#report-num ) + ".txt":u ) .
   output stream forexcel to value( string( session:temp-directory ) +
                              {&df_name} + string( g#report-num ) + ".txt":u ) .

reportheader =  "".
reportname   =  "".
str1 =  "".
str2 =  "".
str3 =  "".
str4 =  "".
run rep/extitle.p (1) no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  ""
  view-as alert-box error
.
Sheetf.Bas-Params =
      p-name            + {&delim-par} +
      p-dostavka        + {&delim-par} +
      p-telefon-1       + {&delim-par} +
      p-telefon-2       + {&delim-par} +
      p-info            + {&delim-par} +
      p-orderinfo       + {&delim-par} +
      p-action          + {&delim-par} +
      p-skidki          + {&delim-par} +
      p-skidki-2        + {&delim-par} +
      p-skidki-3        + {&delim-par} +
      p-skidki-4        + {&delim-par} +
      p-skidki-5        + {&delim-par} +
      p-skidki-6        + {&delim-par} +
      p-skidki-7        + {&delim-par} +
      p-skidki-8        + {&delim-par} +
      string(p-colsize) + {&delim-par} +
      p-hot             + {&delim-par} +
      v-dircode1        + {&delim-par} +
      v-dircode2

      .
        for each  temp-list break by temp-list.f-sort :
          {&putexcel}
            temp-list.artic  {&tabulation}
            temp-list.b-code    {&tabulation}
            temp-list.gds-name  {&tabulation}
            temp-list.price-sal {&tabulation}
            temp-list.min-part  {&tabulation}
            temp-list.f-name    {&tabulation}
            {&new-line}
            .
        end.



if session:set-wait-state("") then.
 {&closeexcel}
 run rep/runexcel.p (string( session:temp-directory) + {&df_name} + string( g#report-num ) + ".txt").

os-delete value( string( session:temp-directory ) +
                           {&df_name} + string( g#report-num ) + ".txt":u ) .



/* **********************  Internal Procedures  *********************** */

procedure get_price:
/*------------------------------------------------------------------------------
		Purpose: Узнать цену товара по группе покупателей
------------------------------------------------------------------------------*/

define input parameter p-obj-type as character no-undo.
define input parameter p-obj-code as integer no-undo.
define input parameter p-bgr-id as integer no-undo.
define input parameter p-bgr-db-num as integer no-undo.
define input parameter p-gds-code as integer no-undo.
define input parameter p-fact-order as decimal no-undo.
define output parameter p-price-sale as decimal no-undo.

define variable v-root-b-code as integer no-undo.

{gbl/gdsbcode.i
 p-gds-code
 ?
 v-root-b-code
 no-error}

for first buf_price-all no-lock use-index by_fact-order where
    buf_price-all.obj-type = p-obj-type and
    buf_price-all.obj-code = p-obj-code and
    buf_price-all.main-indication = 0 and
    buf_price-all.b-code = v-root-b-code and
    buf_price-all.bgr-id = p-bgr-id and
    buf_price-all.bgr-db-num = p-bgr-db-num and
    ((buf_price-all.fact-order-sys-from = 0) or (buf_price-all.fact-order-sys-from <= p-fact-order)) and
    ((buf_price-all.fact-order-sys-to = 0) or (buf_price-all.fact-order-sys-to >= p-fact-order))
    by buf_price-all.fact-order descending:
        p-price-sale = buf_price-all.price-sale.
end.

end procedure.
