/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция обработки отмеченных записей при открытии запроса в run-time

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/23/05
Author: Bakhtadze Natalya
Creation date: 10/23/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :

  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).

END FUNCTION.

/* $Workfile$ e n d */