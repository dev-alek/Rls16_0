/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обнуление счетчика наличных в IBS TH POS

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/27/09
Author: Bakhtadze Natalya
Creation date: 01/27/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_clear-cash-counter
{&run_proc_libthpos}
   {1} .




/* $Workfile$ e n d */

