/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обновляем дату первого и последнего дня движения по товару

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if  {1}first-doc <> ?
and {1}first-doc > {2}fact-date then do:
  assign
    {1}first-doc  = {2}fact-date
  .
end.
if  {1}last-doc <> ?
and {1}last-doc < {2}fact-date then do:
  assign
    {1}last-doc   = {2}fact-date
  .
end.
/* $Workfile$ e n d */