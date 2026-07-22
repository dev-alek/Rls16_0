/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

разбор записи prod-bc из пакета

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

run check-avail-b-code in p-imp-handle
  ( input-output wt-prod-bc.b-code
  ).
run create-prod-bc in p-imp-handle
  ( input wt-prod-bc.b-code, input wt-prod-bc.b-str, input wt-prod-bc.bc-on, input wt-prod-bc.cr-db-num, input wt-prod-bc.bc-on-type
  ).
/* $Workfile$ e n d */