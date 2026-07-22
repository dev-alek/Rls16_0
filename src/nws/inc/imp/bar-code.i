/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

разбор записи bar-code из пакета новостей

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/06
Author: Dmitry Ukhanov
Creation date: 03/23/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

run create-bar-code in p-imp-handle
  ( input wt-bar-code.b-code
   ,input wt-bar-code.cli-base-rate
   ,input wt-bar-code.gds-code
   ,input wt-bar-code.in-code
   ,input wt-bar-code.node-code
   ,input wt-bar-code.part-code
   ,input wt-bar-code.unit-cli
   ,input wt-bar-code.cr-db-num
  ).

/* $Workfile$ e n d */