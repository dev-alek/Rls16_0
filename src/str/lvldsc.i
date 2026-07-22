/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для пороговой наценки

Автор: Чернова Светлана Александровна
Дата создания: 02/17/10
Author: Svetlana Chernova
Creation date: 02/17/10

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table tt-level-dis-attr no-undo
      field attr-code   like global-state-attr.attr-code
      field attr-value  like global-state-attr.attr-value
      index pi   attr-value descending
      index pi1 is unique attr-value
            attr-code .


procedure lvldsc-byattr :
define input  parameter p-attr-code  as character no-undo .
define input  parameter p-attr-value as character no-undo .
define output parameter p-val1       as decimal   no-undo .
define output parameter p-val2       as decimal   no-undo .
define output parameter p-prc        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
  define variable v-str1 as character no-undo .

  v-str1 = trim ( p-attr-code , {&attr-pal-level-discnt} ) .
  v-str1 = trim ( v-str1 , {&delim-par} ) .

 run lvldsc-bytt (
      input   v-str1
    , input   p-attr-value
    , output  p-val1
    , output  p-val2
    , output  p-prc )
      no-error .
  end.

end procedure. /* lvldsc-byattr */


procedure lvldsc-bytt :
define input  parameter p-attr-code as character no-undo .
define input  parameter p-attr-value as character no-undo .
define output parameter p-val1 as decimal   no-undo .
define output parameter p-val2 as decimal   no-undo .
define output parameter p-prc  as decimal   no-undo .

define variable v-str1 as character no-undo .
  do
  on error undo, return error return-value
  :
  assign
     v-str1 = trim ( p-attr-code , "[]()" )
     p-val1 = decimal(entry(1,v-str1, ";"))
     p-val2 = decimal(entry(2,v-str1, ";"))
     p-prc  = decimal(p-attr-value)
     no-error
  .
  /*
  message
    'v-str1' v-str1 skip
    'p-val1' p-val1 skip
    'p-val2' p-val2 skip
    'p-prc ' p-prc  skip
    .
    */

  end.

end procedure. /* lvldsc-bytt */


procedure level-dis-value :
define input  parameter p-price-prod as decimal   no-undo . /* Цена производителя без НДС */
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-prc as decimal   no-undo .        /* разрешенный % наценки      */
define variable v-level-dis-attr as character no-undo .
define variable v-type as character no-undo .
define variable v-val1 as decimal   no-undo .
define variable v-val2 as decimal   no-undo .
define variable v-prc  as decimal   no-undo .
define variable ix     as integer   no-undo .
do
 on error undo, return error return-value
 :

define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .

find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .

run ggoattr-value (
   input   buf_goods.grp-code
  ,input   v-cntxt-host-code-obj
  ,input   p-obj-type
  ,input   p-obj-code
  ,input   {&ggoattr-level-dis}
  ,output  v-level-dis-attr
  ,output  v-type ) no-error .

repeat ix = 1 to num-entries (v-level-dis-attr, {&delim-par}) - 1 :
  create
    tt-level-dis-attr
  .
  tt-level-dis-attr.attr-code = entry (1, entry (ix, v-level-dis-attr, {&delim-par}), {&comma-char}) .
  tt-level-dis-attr.attr-value = entry (2, entry (ix, v-level-dis-attr, {&delim-par}), {&comma-char}) .
end.



p-prc = 0 .

  if p-price-prod = 0 then do:
      for each tt-level-dis-attr no-lock
              :
            run lvldsc-bytt (
              input   tt-level-dis-attr.attr-code
            , input   tt-level-dis-attr.attr-value
            , output  v-val1
            , output  v-val2
            , output  v-prc  )
            .
            if v-val1  = 0  then do:
               p-prc = v-prc .
              leave.
            end.
      end.
  end.
  else do:
      for each tt-level-dis-attr no-lock
              :
            run lvldsc-bytt (
              input   tt-level-dis-attr.attr-code
            , input   tt-level-dis-attr.attr-value
            , output  v-val1
            , output  v-val2
            , output  v-prc  )
            .
            if p-price-prod   > v-val1 and
               p-price-prod  <= v-val2 then do:
               p-prc = v-prc .
              leave.
            end.
      end.
  end.
for each tt-level-dis-attr no-lock. delete tt-level-dis-attr. end.
 end.

end procedure. /* level-dis-value */


procedure calc-price-levelprod :
define input  parameter p-mode     as integer   no-undo . /* 1- цены с НДС; 2 - цены без ндс */
define input  parameter p-rb       as character no-undo .
define input  parameter p-b-code   as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-price-sale as decimal   no-undo .
define output parameter p-descript-calc as character no-undo .

define variable  v-PriceWithoutVat as decimal   no-undo init 0.
define variable  v-PriceWithVat    as decimal   no-undo init 0.
define variable  v-prod-vat        as decimal   no-undo init 0.
define variable  v-discnt          as decimal   no-undo init 0.

define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_parts for ub.parts  .
define variable v-part-code as character no-undo .
define variable v-in-code   as character no-undo .
  do
  on error undo, return error return-value
  :

/* цены производителя */
    { gbl/proprice.i
      p-b-code
      p-obj-type
      p-obj-code
      v-PriceWithoutVat
      v-PriceWithVat
      v-prod-vat
      v-part-code
      v-in-code
      no-error }
      if error-status :error then do:
        return error "Нет цены производителя!".
      end.
/* цены поставщика */
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .

find first buf_parts no-lock where
           buf_parts.artic      = buf_goods.artic        and
           buf_parts.prod-type  = buf_goods.prod-type    and
           buf_parts.prod-code  = buf_goods.prod-code    and
           buf_parts.in-code    = buf_bar-code.in-code   and
           buf_parts.out-code   = buf_bar-code.in-code   and
           buf_parts.part-code  = buf_bar-code.part-code
           no-error .
            if error-status :error then do:
                find first buf_parts no-lock where
                          buf_parts.artic      = buf_goods.artic        and
                          buf_parts.prod-type  = buf_goods.prod-type    and
                          buf_parts.prod-code  = buf_goods.prod-code    and
                          buf_parts.in-code    = v-in-code              and
                          buf_parts.out-code   = v-in-code              and
                          buf_parts.part-code  = v-part-code
                          no-error .
                if error-status :error then do:
                   message
                    substitute("Нет цены производителя !  &1 &2&3&4&5"  ,
                                v-in-code,
                                v-part-code ,
                                buf_goods.artic   ,
                                buf_goods.prod-type,
                                buf_goods.prod-code ) .
                   return error "Нет цены производителя !!!".
                end.
            end.

 /* % наценки */
run level-dis-value ( input (if p-mode = 2 then v-PriceWithoutVat else v-PriceWithVat) , input p-b-code, input p-obj-type, input p-obj-code, output v-discnt ) no-error .

define variable v-postWithoutVat-rubl as decimal   no-undo .
define variable v-postWithoutVat-base as decimal   no-undo .
   case p-mode :
    when 1 then do:
       if p-rb = "rubl" then do:
          p-price-sale = buf_parts.price-rubl + ( MINIMUM ( buf_parts.price-rubl , v-PriceWithVat ) * v-discnt / 100 ).
       end.
       else do:
          p-price-sale = buf_parts.price-base + ( MINIMUM ( v-PriceWithVat , buf_parts.price-base ) * v-discnt / 100 ).
       end.
    end.
    when 2 then do: /* без */
      if p-rb = "rubl" then do:
        v-postWithoutVat-rubl =  buf_parts.price-rubl - (buf_parts.price-rubl * buf_parts.vat-pc / (100 + buf_parts.vat-pc) ).
        p-price-sale = v-postWithoutVat-rubl + ( MINIMUM ( v-PriceWithoutVat , v-postWithoutVat-rubl ) * v-discnt / 100 ) .
      end.
      else do:
        v-postWithoutVat-base = buf_parts.price-base - (buf_parts.price-base * buf_parts.vat-pc / ( 100 + buf_parts.vat-pc) ) .
        p-price-sale = v-postWithoutVat-base + ( MINIMUM ( v-PriceWithoutVat, v-postWithoutVat-base) * v-discnt / 100 ) .
      end.
    end.
   end case.

p-descript-calc =
  string(p-mode) + '_Элементы расчета: ' +  {&new-line}  +
  buf_goods.gds-name                  +  {&new-line} +
  buf_goods.artic +
  buf_goods.prod-type +
  string(buf_goods.prod-code)         + {&new-line} +
  "бар-код " +  string(p-b-code)      + {&new-line}  +
  'ПН    ' + v-in-code  +
  ' серия ' + v-part-code             +  {&new-line}  + {&new-line} +
  'Цена поставщика без ндс    '  + string((buf_parts.price-rubl - (buf_parts.price-rubl * buf_parts.vat-pc / (100 + buf_parts.vat-pc) ) ))  + {&new-line} +
  'Цена поставщика   c ндс    '  + string ( buf_parts.price-rubl )  + {&new-line} +
  'Цена производителя без ндс ' +  string( v-PriceWithoutVat)       + {&new-line} +
  'Цена производителя   c ндс ' +  string( v-PriceWithVat  )        + {&new-line} +
  {&new-line} +
  "% пороговой наценки        "  + string(v-discnt)                 + {&new-line} +
  {&new-line} +
  "сумма наценки от произв без ндс "  + string( v-PriceWithoutVat * v-discnt / 100 ) +  {&new-line} +
  "сумма наценки от произв   с ндс "  + string( v-PriceWithVat * v-discnt / 100 )    +  {&new-line}  +
  {&new-line} +
  string(p-price-sale)                                                               +  {&new-line} +
  (if p-mode = 1 then substitute("ПорогПр+НДС  &1 + ( min(&2или &1) * &3 / 100 )  = &4 " , buf_parts.price-rubl , v-PriceWithVat , v-discnt , p-price-sale)
  else                substitute("ПорогПр-НДС  &1 - ( &1 * &2 / 100 ) + ( min(&3 или &6 ) * &4 / 100 ) = &5 и еще накручивается НДС " , buf_parts.price-rubl , buf_parts.vat-pc , v-PriceWithoutVat , v-discnt , p-price-sale , v-postWithoutVat-rubl))

.
 /*message p-descript-calc .*/

  end.
end procedure. /* calc-price-levelprod */