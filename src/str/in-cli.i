/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение цены в валюте поставщика исходя из учетной цены в валюте прайс-листа.

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

Учетная цена ВСЕГДА включает НДС!!!
{1} - def - определение переменных
      calc - расчет цены поставщика
{2} - буффер для расчета цены
{3} - буффер откуда берем курсы, vat-type, slt-type
{4} - суффикс переменной
*/

&if "{1}" = "def" &then
  def var price-cli-loc{4} like ub.doc-line.price-cli no-undo .
  def var varr-b{4}        as   character             no-undo.
&endif
&if "{1}" = "calc" &then
if varr-b = "rubl":u then do:
  assign
  price-cli-loc{4} =
    ( ( {2}price-rubl
      - {2}transport-rubl
      - {2}other-rubl
      - {2}road-tax-rubl
      )
      *
      ( if {3}slt-type = {&no-slt}
        then 100 / (100 + {2}slt-pc)
        else 1
      )
      *
      ( if {3}vat-type = {&no-vat}
        then 100 / (100 + {2}vat-pc)
        else 1
      )
      + {2}road-tax-rubl
    )
    / {3}exch-rate *  {3}exch-scale * {2}cli-base-rate
    .
end.
else do:
  assign
  price-cli-loc{4} =
    ( ( {2}price-base
      - {2}transport-base
      - {2}other-base
      - {2}road-tax-base
      )
      *
      ( if {3}slt-type = {&no-slt}
        then 100 / (100 + {2}slt-pc)
        else 1
      )
      *
      ( if {3}vat-type = {&no-vat}
        then 100 / (100 + {2}vat-pc)
        else 1
      )
      + {2}road-tax-base
    )
      * {3}base-rate / {3}base-scale
    / {3}exch-rate *  {3}exch-scale * {2}cli-base-rate
    .
end.
&endif
/* $Workfile$ e n d */