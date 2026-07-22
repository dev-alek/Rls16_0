/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка - есть ли нетоварные позиции

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name lib-trn3_resv-inqv
{&run_proc_lib-trn3}
(input  {1},  /*pardoc-code  */
 output {2}   /*par-exit     */
) {3}
.
/* $Workfile$ e n d */