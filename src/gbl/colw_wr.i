/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись ширины колонок в базу данных

Автор: Перваков Михаил Сергеевич
Дата создания: 09/07/06
Author: Mikhail Pervakov
Creation date: 09/07/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(include_colwidth) = 0 &then
  &message need include gbl/colwidth.i
&endif
run colwidth-write in this-procedure
 {1} .
/* $Workfile$ e n d */