/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов программы установки специальных продажных цен при продаже по партиям

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/27/06

{1} - def или calc
{2} - номер документа
{3} - тип объекта
{4} - код объекта
{5} - артикул товара
{6} -
*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" = "def" &then
   define variable varsaleparts     as   logical               no-undo.
   define variable varsp-sum-price-sale like price-list.price-sale no-undo.
   define variable varsp-sum-road-tax   like price-list.road-tax   no-undo.
   define variable varsp-sum-excise     like price-list.excise     no-undo.
   define variable varsp-prc-price-sale like price-list.price-sale no-undo.
   define variable varsp-prc-road-tax   like price-list.road-tax   no-undo.
   define variable varsp-prc-excise     like price-list.excise     no-undo.
&endif
&if "{1}" = "calc" &then
   run str/set-prsp.p (input {2},
                   input {3},
                   input {4},
                   input {5},
                   input {6},
                   input {7},
                   output varsaleparts        ,
                   output varsp-sum-price-sale,
                   output varsp-sum-road-tax  ,
                   output varsp-sum-excise    ,
                   output varsp-prc-price-sale,
                   output varsp-prc-road-tax  ,
                   output varsp-prc-excise    ) no-error.
   if error-status:error then do:
      message return-value view-as alert-box.
      return error.
   end.
   if varsaleparts         = yes and
      varsp-prc-price-sale = ?   then do:
      message "Нельз
   end.
&endif
/*end of set-prsp.i*/