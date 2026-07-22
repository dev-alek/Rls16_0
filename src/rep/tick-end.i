/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

печать этикеток (окончательное действие)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/05
Author: Dmitry Ukhanov
Creation date: 11/29/05

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

OUTPUT STREAM OutStream CLOSE.
message
  substitute( "Передано на печать &1 этикеток (ценников)", b-count )
  view-as alert-box INFORMATION.
os-command NO-WAIT value( substitute( "start &1run-lbc.bat &1 &2title &3 &4", lbc-path, lbc-tmp, TicketName, v-user-id ) ).

/* $Workfile$ e n d */