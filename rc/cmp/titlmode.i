/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Фукнция определения корректного для данного языка значения моды для титла окна

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/30/01
Author: Bakhtadze Natalya
Creation date: 08/30/01

*/

/*требует хотя бы trg-def.i */

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION title-mode RETURNS CHARACTER
  ( INPUT pmode as character ) :

DEFINE VARIABLE ptitle-mode as character no-undo.

CASE ENTRY(1, pmode) :

  when {&add-def} then ptitle-mode = "{&bef-add-def}".
  when {&update}  then ptitle-mode = "{&bef-update}".
  when {&lookup}  then ptitle-mode = "{&bef-lookup}".

END CASE.

  RETURN ptitle-mode.   /* Function return value. */

END FUNCTION.

/* $Workfile$ e n d */