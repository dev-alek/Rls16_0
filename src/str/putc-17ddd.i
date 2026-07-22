/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсылка ШК на кассу - вывод

Автор: Шкляр Елена
Дата создания: 02/19/06
Author: Shklyar Elena
Creation date: 02/19/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  v-version-dec = decimal(p-pos-version)
    no-error .

for each ub.PromoGoods no-lock where ub.PromoGoods.db-num = integer(entry(2,ub.PromoAttr.p-key,{&delim-key})) and
  ub.PromoGoods.idAction = int64(entry(1,ub.PromoAttr.p-key,{&delim-key})) and
  ub.PromoGoods.gds-code = integer(entry(3,ub.PromoAttr.p-key,{&delim-key})):
  find first ub.goods no-lock where ub.goods.gds-code = ub.PromoGoods.gds-code no-error .
  for first ub.bar-code no-lock where ub.bar-code.gds-code = ub.goods.gds-code and ub.bar-code.b-code = ub.goods.gds-code:
    producer-int = (if ub.goods.prod-type = {&cmp} then 1000000 else 0 ) + ub.goods.prod-code .
    run gds-attr-value in this-procedure (
      input ub.goods.gds-code
      ,input {&attr-emrc-type}
      ,output v-attr-emrc
      ,output v-attr-type) no-error.
    run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'" 
      , "DEL":U    
      , OS2-time         
      , string(ub.PromoAttr.attr-value))).                                              
    run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"                                          
      , input string( ub.bar-code.b-code )
      , input 1 ).                                                                                                                                     
    run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"                                      
      , input string(producer-int), input 1 ).                   
    run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"                                    
      , input trim(string( ub.goods.struct, "X(40)")), input 1 ).                
    find first country no-lock where country.alpha1 = ub.goods.alpha1 no-error.                              
    if available country then                                                                                
      run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"                                       
        , input country.short-name, input 1 ).                              
    find last ub.price-all no-lock where ub.price-all.gds-code = ub.goods.gds-code and 
      ub.price-all.obj-code = i-obj-code and 
      ub.price-all.obj-type = {&shop} and
      ub.price-all.main-indication = 0 and
      ub.price-all.type-price = 0 no-error .
    if available (ub.price-all) then 
    do:
       run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"                                         
         , input string(ub.price-all.price-sale)
         , input 1 ).
    end.
    else do:
       run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"                                         
         , input "0"
         , input 1 ).
    end.                   
    run bgelib-tag-put in this-procedure ( input 3, input "IBCType"                                         
      , input string( 0 ), input 1 ).                   
    run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                        ~
      , input  v-attr-emrc, input 1 ).                                    
    run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                   ~
      , input  string(ub.bar-code.cli-base-rate), input 1 ).  
    run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
  end.
end.
