/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Cоздание записи таблицы связей при создании route-dump

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/15/10
Author: Dmitry Ukhanov
Creation date: 02/15/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-nws_route-dump-write
{&run_proc_lib-nws}
  ( input {1} /* p-tbl-name */
  , input {2} /* p-bh_rtd   */
  , input {3} /* p-bh       */
  , input {4} /* p-dmp-ord  */
  , input {5} /* p-rc-ord   */
  ) {6} .

/* $Workfile$   E n d */
