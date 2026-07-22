/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение текущей цены бар-кода

Автор: Чернова Светлана Александровна
Дата создания: 10/09/06
Author: Svetlana Chernova
Creation date: 10/09/06

   {1} - если определение переменных, то def
   Поиск текущей продажной цены по объекту
   c типом объекта = {2},
   и кодом объекта = {3}
   цена ищется для признака
   c gds-code      = {4}
   с node-code     = {5}, если она неизвестна, то для корня товара
   undo-action     = {6}

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{6}" = "" &then
  &scop undo-action return error.
&else
  &scop undo-action {6}
&endif

&if "{1}" = "def" &then
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
&else

&if "{7}" = "" &then gp-fact-order = 0 .
               &else gp-fact-order = {7} .
&endif

{ gbl/gdsbcode.i {4} {5} gp-b-code no-error}
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  {&undo-action}
end.

{ gbl/bcodeprc.i "{2}" "{3}" gp-b-code 0 gp-fact-order gp-doc-num gp-price-sale gp-road-tax gp-excise no-error }
if error-status:error then do:
  {&undo-action}
end.

gp-price-sale-parts = gp-price-sale.

/*  проверить цены по кодам партий */

{ gbl/avprpart.i "{2}" "{3}" gp-b-code 0 gp-fact-order gp-doc-num gp-price-sale-parts gp-road-tax gp-excise no-error }
if error-status:error then do:
  {&undo-action}
end.

if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.

&endif

/* $Workfile$ e n d */