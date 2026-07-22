/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение товар является НАБОРОМ или нет    живет в lib-trn3

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 01/18/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name  lib-trn3_grp-nabor
{&run_proc_lib-trn3}
( input  {1} ,  /*par-gds-code       goods.gds-code */
  output {2}    /*par-nabor          no - не набор   */
) {3}
.

/* $Workfile$ e n d */