/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Определения для libthpos

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/08
Author: Bakhtadze Natalya
Creation date: 07/16/08

*/


define temp-table libthpos_cash-desk-attr like ub.cash-desk-attr.
temP-TABLE libthpos_cash-desk-attr:HANDLE:SCHEMA-MARSHAL = "NONE".

define dataset libthpos_params  for libthpos_cash-desk-attr.


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".




/* $Workfile$ e n d */
