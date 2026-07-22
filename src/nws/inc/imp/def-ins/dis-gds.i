/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема скидок товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/06/06
Author: Bakhtadze Natalya
Creation date: 12/06/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-to-del as logical no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.

for each locb-dis-gds-rule
on error undo, return error error-status :get-message (1)
:
  delete locb-dis-gds-rule.
end.

/* $Workfile$ e n d */