/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгрузка на кассу MAGIA-XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/18/03
Author: Bakhtadze Natalya
Creation date: 08/18/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define variable mi-entry as integer no-undo .
define variable v-out-code like ub.fbr-gds-grp.out-code no-undo .
define variable v-out-code-0 like ub.fbr-gds-grp.out-code no-undo .
define variable v-global-code like ub.fbr-gds-grp.global-code no-undo .
define variable v-xml-vat like ub.tax-rate-value.rate-value no-undo .
define variable v-xml-slt like ub.tax-rate-value.rate-value no-undo .

define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer buf_tax-rate for ub.tax-rate.
find first buf_fbr-gds-grp no-lock where
           buf_fbr-gds-grp.obj-type = {&shop}
       AND buf_fbr-gds-grp.obj-code = i-obj-code
      AND buf_fbr-gds-grp.node-code = cash-gds.fbr-grp-code no-error .
if avail buf_Fbr-gds-grp then do:
  assign
  v-out-code = buf_fbr-gds-grp.out-code
  v-global-code = buf_fbr-gds-grp.global-code
  .
end.
else do:
  assign
  v-global-code = cash-gds.fbr-grp-code-0
  .
end.
if v-global-code  > 0
then do:
  find first buf_fbr-gds-grp no-lock where
            buf_fbr-gds-grp.obj-type = "":U
        AND buf_fbr-gds-grp.obj-code = 0
        AND buf_fbr-gds-grp.node-code = v-global-code no-error .
  if avail buf_Fbr-gds-grp then do:
    assign
    v-out-code-0 = buf_fbr-gds-grp.out-code
    .
  end.
  else do:
    v-out-code-0 = 0.
  end.
end.
if v-out-code = 0
and cash-gds.is-modificator = 0
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Ошибка при получении характеристик товара &1 &2 на объекте: &3"
                            , cash-gds.gds-code
                            , cash-gds.gds-name
                            , "не указана группа меню на кассе"
                            )
                              ).
    assign
    v-view-log = yes
    .
end.

if v-out-code <> 0
or v-is-modificator
then do:

  run bgelib-tag-open in this-procedure ( input 2, input "Item", input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U":U then "ADD" else "DEL":U), OS2-time, cash-gds.b-code)).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemName"       , input trim(second-name, {&space-char}), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemAltName"    , input trim(chk_name, {&double-quote}), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemMainPrice"  , input string(0), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemPriceCurrency"  , input string(v-r-b-curr-magia), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemGroup"      , input string( if v-out-code-0 = 0 then 9998 else v-out-code-0), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemDepartId"   , input string( cash-gds.departid ), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemLock"       , input (if action = "U":U then string(0) else string(1)), input 1 ).

  run bgelib-tag-open in this-procedure ( input 3, input "ItemStatus"        ,       input "" ).
  run bgelib-tag-put in this-procedure ( input 4, input "ISNullPrice"        , input string( cash-gds.zp ), input 1 ).
  run bgelib-tag-put in this-procedure ( input 4, input "ISMenu"            , input string( cash-gds.is-menu ), input 1 ).
  run bgelib-tag-put in this-procedure ( input 4, input "ISSemiFinished"     , input string( cash-gds.is-semi-finished ), input 1 ).
  run bgelib-tag-put in this-procedure ( input 4, input "ISModificator"     , input string( cash-gds.is-modificator ), input 1 ).
  run bgelib-tag-close in this-procedure ( input 3, input "ItemStatus").

  if tax-cass
  AND action = "U":U then do:
    do mi-entry = 1 to num-entries(cash-gds.tax-string, {&space-char}):
      if entry(mi-entry, cash-gds.tax-string, {&space-char}) <> "":U then do:
        find first buf_tax-rate no-lock where
                    buf_tax-rate.rate-code = integer(entry(mi-entry, cash-gds.tax-string, {&space-char})) no-error .
        if available buf_tax-rate
        and buf_tax-rate.tax-code = vattaxcd then do:
          { gbl/pftaxval.i recid(buf_tax-rate) buf_tax-rate.tax-code buf_tax-rate.rate-code  v-today  shop.host-code  {&shop} shop.obj-code v-xml-vat no-error }
          if not error-status:error  then do:
            run bgelib-tag-open in this-procedure ( input 3, input "ItemTax", input "" ).
            run bgelib-tag-put in this-procedure ( input 4, input "ITName"  , input "Vat":U, input 1 ).
            run bgelib-tag-put in this-procedure ( input 4, input "ITValue"  , input string(v-xml-vat), input 1 ).
            run bgelib-tag-close in this-procedure ( input 3, input "ItemTax").
          end.
        end.
      end.
    end.
  end.


  /*
  PriceListProd :
          [PriceListID] smallint,        ID прайс-листа
          [ProdID] int,                  ID продукта
          [PriceGroupID] smallint,       ID группы в прайс-листе
          [FlagLocalExcess] bit,         Использовать свой (а не общий признак наличия в продаже)
          [Excess] bit,                  Признак наличия в продаже
                                            (имеет смысл при FlagLocalExcess=1
          [FlagLocalCost] bit,           Флаг локальной (а не общей)цены.
          [ProductCost] float,           Цена
          [ProductCostCurrID] smallint   Валюта цены.
  */

  run bgelib-tag-close in this-procedure ( input 2, input "Item").
  if v-out-code > 0 then do:
    /*сюда не попадут модификаторы НЕ привязанные  к группе прейскуранта но ВООБЩЕ в блюда они попадут*/
    &if "{&called}" = "in-ov" &then
    run bgelib-tag-open in this-procedure ( input 2, input "ItemPriceList", input substitute("ctrl='&1' tms='&2' code='&3'", 'ADD', OS2-time, cash-gds.b-code)).
    &else
    run bgelib-tag-open in this-procedure ( input 2, input "ItemPriceList", input substitute("ctrl='&1' tms='&2' code='&3'",  (if action = "U":U then 'ADD' else "DEL":U), OS2-time, cash-gds.b-code)).
    &endif
    run bgelib-tag-put in this-procedure ( input 3, input "IPLId"  , input string( i-obj-code ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "IPLGroup"      , input string( v-out-code ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "IPLFlagLocalExcess", input string(1 ), input 1 ).
    &if "{&called}" = "in-ov" &then
      if action = "D":U then do:
        run bgelib-tag-put in this-procedure ( input 3, input "IPLLock"  , input string(1), input 1 ).
      end.
      else do:
        run bgelib-tag-put in this-procedure ( input 3, input "IPLLock", input string(0), input 1 ).
      end.
    &else
        run bgelib-tag-put in this-procedure ( input 3, input "IPLLock"
                                            , input (if action = "D":U then string(1) else string(0)), input 1 ).
    &endif
    run bgelib-tag-put in this-procedure ( input 3, input "IPLFlagLocalPrice", input string(1 ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "IPLPrice"  , input string( cash-gds.price-sale ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "IPLPriceCurrency"  , input string(v-r-b-curr-magia), input 1 ).
    run bgelib-tag-close in this-procedure ( input 2, input "ItemPriceList").
  end.
end.


/* $Workfile$ e n d */