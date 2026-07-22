/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы для разбора шаблона печати

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/10/03
Author: Bakhtadze Natalya
Creation date: 07/10/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table t-f no-undo
field table-name as character
field field-name as character
field field-name-0 as character
field field-format as character
field field-type as character
field field-size as character
field field-csize as integer
field field-label as character
field field-clabel as character
field field-spr as character
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



/* $Workfile$ e n d */