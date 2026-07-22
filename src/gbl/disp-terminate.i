/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закрытие дисплея покупателя.

Автор: Белоусов Илья Александрович
Дата создания: 09/12/08
Author: Ilia Belousov
Creation date: 09/24/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name disp-terminate
do:
  {&run_proc_disp-lib}
    ( output {1}  /* p-err-message     */
    , output {2}  /* p-ok              */
    ) {3} .
end.

/* $Workfile$ e n d */