/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие смены ФР

Автор: Белоусов Илья Александрович
Дата создания: 07/28/08
Author: Ilia Belousov
Creation date: 07/28/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name fr-shtop
do:
  {&run_proc_fr-lib}
    ( output       {1}  /* p-err-message         */
    , output       {2}  /* p-ok               */
    ) {3} .
end.

/* $Workfile$ e n d */