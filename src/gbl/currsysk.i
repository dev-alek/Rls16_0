/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение sys-key

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/05/09
Author: Dmitry Ukhanov
Creation date: 10/05/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
&scop proc-name currsysk
{&run_proc_library}
  (output {1} /* p-sys-key */
  ) {2} .
/* $Workfile$ e n d */