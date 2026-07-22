/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

функция возврата года из 4-х цифр

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/30/03
Author: Bakhtadze Natalya
Creation date: 05/30/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION yearofst RETURNS integer
  ( input p-year as integer ) :


DEFINE VARIABLE v-year-true as integer no-undo .
DEFINE VARIABLE v-y-o as integer no-undo .
DEFINE VARIABLE v-ost as integer no-undo .
if p-year < 0 or p-year > 99 then return ?.

assign
v-y-o = session:year-offset
v-ost = (v-y-o MODULO 100)
v-year-true = (if p-year < v-ost
               then (v-y-o + (v-y-o MODULO 100) + p-year)
               else (v-y-o - v-ost + p-year))
.
return v-year-true.
END FUNCTION.


/* $Workfile$ e n d */