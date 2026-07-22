/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подсчет плотности
Используется в ПН

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/23/09
Author: Dmitry Ukhanov
Creation date: 12/23/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-calc_clcdens
{&run_proc_lib-calc}
  (
   input   {1} /*parext-gds-type  */
  ,input   {2} /*parcli-qnty      */
  ,input   {3} /*pardoc-qnty      */
  ,output  {4} /*pardensity       */
  ) {5}.

/* $Workfile$ e n d */