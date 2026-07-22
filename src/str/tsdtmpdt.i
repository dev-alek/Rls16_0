/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы для разбора шаблона выгрузки в файл ТСД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/10/03
Author: Bakhtadze Natalya
Creation date: 07/10/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&GLOBAL-DEFINE delim-ascii-codes string(asc(~{&comma-char~})) + ',1,2,3,4,5,6,7,0,59':U

define {1} temp-table t-f no-undo
field table-name as character
field field-name as character
field field-name-0 as character
field field-format as character
field field-type as character
/*длина рекомендованная - макс*/
field field-size as character
/*длина минимальная*/
field field-size-min as character
/*длина выбранная пользователем*/
field field-csize as character
field field-label as character
field field-clabel as character
field field-spr as character
field field-delim as character
/*порядок поля в пределах данной таблицы*/
field field-table-order as integer
/*порядок поля в пределах выбранных полей*/
field field-order as integer
index pi is unique primary
table-name
field-name
index iorder
field-order
index itorder
table-name
field-table-order
.

define {1} temp-table temp-shop no-undo
like ub.shop.

/* $Workfile$ e n d */