/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Есть работа с ORacle REtail

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/27/09
Author: Bakhtadze Natalya
Creation date: 03/27/09

метод не затрагивающий sys-key

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION isoraret_on returns logical :
define buffer buf_ext-system for ub.ext-system.
define buffer buf_db for ub.db  .

find first buf_db no-lock where buf_db.db-num > 0 no-error .
if available buf_db then  do:
   return no.
end.

find first buf_ext-system no-lock no-error .
if available buf_ext-system
and buf_ext-system.esys-type = integer({&openxml-type-oracle-retail})
and buf_ext-system.delivery-method = integer({&esys-dm-oracle-retail}) then return yes.
return no.
end function.



/* $Workfile$ e n d */