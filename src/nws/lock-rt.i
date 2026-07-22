/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

блокировка маршрутизации СПН

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/15/10
Author: Dmitry Ukhanov
Creation date: 02/15/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-nws_lock-route
{&run_proc_lib-nws}
  ( input  {1} /* p-action  */
  , input  {2} /* p-db-num  */
  , input  {3} /* p-esys-id */
  , input  {4} /* p-descr   */
  , output {5} /* p-msg     */
  , output {6} /* p-lock    */
  , output {7} /* p-ok      */
  ) {8} .

/* $Workfile$   E n d */