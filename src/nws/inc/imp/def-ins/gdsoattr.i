/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема атрибутов товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/30/03
Author: Bakhtadze Natalya
Creation date: 06/30/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-type           as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable jj as integer no-undo .
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .

define buffer buf_goods for ub.goods.

for each locb-gds-obj-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-gds-obj-attr.
end.
/* $Workfile$ e n d */