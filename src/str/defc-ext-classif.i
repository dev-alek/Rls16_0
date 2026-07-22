/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы по таблице соответствий

Автор: Шкляр Елена
Дата создания: 16/10/20202
Author: Shklyar Elena
Creation date: 16/10/20202

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE ext-classif-list no-undo
   FIELD db-num as integer
   field Key#One as integer
   field Key#Two as integer
   field CharKey_One as character
/*   field classif-subject as character*/
/*   field classif-name as character   */
index pi IS PRIMARY unique db-num Key#Two Key#One CharKey_One
.

DEFINE {1} TEMP-TABLE c-ext-classif-list no-undo
   FIELD db-num as integer
   field Key#One as integer
   field Key#Two as integer
   field CharKey_One as character
   field chip-num as integer
/*   field classif-subject as character*/
/*   field classif-name as character   */
index pi IS PRIMARY unique db-num Key#Two Key#One CharKey_One chip-num 
.
/* $Workfile$ e n d */