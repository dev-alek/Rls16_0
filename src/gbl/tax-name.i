/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Название налогов из таблицы tax

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/11/06

pardef-tax из str-glbl.i
*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
&scop body-find-tax find first bf_tax where bf_tax.tax-code = integer(~{&tax-code~}) no-lock no-error. ~
                    if available bf_tax then do:                                                       ~
                       assign parname-tax = bf_tax.tax-name.                                           ~
                    end.                                                                               ~
                    else assign parname-tax = "Налог ~{&tax-code~}(не задействован)".

do on error undo, return error :
   case pardef-tax:
      when {&vat-tax} then do:
         &scop tax-code   {&vat-tax-code}
         {&body-find-tax}
      end.
      when {&slt-tax} then do:
         &scop tax-code   {&slt-tax-code}
         {&body-find-tax}
      end.
      when {&road-tax} then do:
         &scop tax-code   {&road-tax-code}
         {&body-find-tax}
      end.
      when {&excise-tax} then do:
         &scop tax-code   {&excise-tax-code}
         {&body-find-tax}
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
/*e n d  o f  n a m e - t a x . i*/